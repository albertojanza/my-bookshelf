class SessionsController < ApplicationController

  def facebook_callback
    # Remove me
    #http = Net::HTTP.new "graph.facebook.com", 443
    #request = Net::HTTP::Get.new "/oauth/access_token?client_id=#{ENV['FACEBOOK_KEY']}&redirect_uri=#{facebook_callback_url}&client_secret=#{ENV['FACEBOOK_SECRET']}&code=#{params[:code]}"
    #http.use_ssl = true
    #response = http.request request
    #@result= CGI.parse(response.body)
    #@token = CGI.parse(response.body)["access_token"][0]
    #@spires = CGI.parse(response.body)["access_token"][1]
    #render "callback"

    facebook_oauth(facebook_callback_url)
    redirect_to root_path
  end

  def canvas_callback
    facebook_oauth(canvas_callback_url)
    redirect_to "http://apps.facebook.com/matumba/"
  end

  # This action redirects to facebook to ask for permission.
  # TODO posible refactorization to do this from the navigator, it is not necesary to have our server as a middle man
  def facebook_permission
    #redirect_to "https://graph.facebook.com/oauth/authorize?client_id=#{ENV['FACEBOOK_KEY']}&redirect_uri=#{facebook_callback_url}&publish_stream" #&scope=offline_access%2Cread_stream"

    render :inline =>  "<script> top.location.href='http://graph.facebook.com/oauth/authorize?client_id=#{ENV['FACEBOOK_KEY']}&redirect_uri=#{facebook_callback_url}&publish_stream'</script>"
  end



  def destroy
    session[:user_id] = nil
    redirect_to root_url, :notice => "You have been logged out."
  end



private

  def facebook_oauth(callback)

    http = Net::HTTP.new "graph.facebook.com", 443
    request = Net::HTTP::Get.new "/oauth/access_token?client_id=#{ENV['FACEBOOK_KEY']}&redirect_uri=#{callback}&client_secret=#{ENV['FACEBOOK_SECRET']}&code=#{params[:code]}"
    http.use_ssl = true
    response = http.request request
    token = CGI.parse(response.body)["access_token"][0]
    expires = CGI.parse(response.body)["access_token"][1]
    request  = Net::HTTP::Get.new "me?access_token=#{token}"
    response = http.request request
    user_data = MultiJson.decode response.body

    user = User.find_by_provider_and_uid('facebook', user_data['id'])
    if user && session[:user_id]  && user.id.eql?(session[:user_id])
      #token has expired
      user.update_attributes(:token => token, :expires => expires)
    elsif session[:user_id].nil?  && user
      # We have the user but his session has expired or he logged out previously
      session[:user_id] = user.id
      user.update_attributes(:token => token, :expires => expires, :name => user_data['name'])
    else # NEW USER

      user = User.create do |user|
        user.provider = 'facebook'
        user.uid= user_data['id']
        user.name= user_data['name']
        user.first_name= user_data['first_name']
        user.last_name= user_data['last_name']
        user.username= user_data['username']
        user.link= user_data['link']
        user.locale = user_data['locale']
        user.token = token
        user.expires = expires
      end
        session[:user_id] = user.id

    end 

      if I18n.available_locales.include? current_user.locale.scan(/^[a-z]{2}/).first.to_sym
        I18n.locale =  current_user.locale.scan(/^[a-z]{2}/).first.to_sym
      else
        I18n.locale =   I18n.default_locale
      end
      session[:locale] = I18n.locale

  end





end
