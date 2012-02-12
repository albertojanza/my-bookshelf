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

    authentication = Authentication.find_by_provider_and_uid('facebook', user_data['id'])
    if authentication && session[:user_id]  && authentication.user.eql?(session[:user_id])
      #token has expired
      authentication.update_attributes(:token => token, :expires => expires)
    elsif authentication && session[:user_id]  && !authentication.user.eql?(session[:user_id])
      # the user is logged with twitter and he is adding a facebook account. But he already has an user with the Facebook accountin the system.
      # We have to proceed to merge both user accounts
    elsif session[:user_id]  && authentication.nil?
      # The user is logged in with twitter and he is adding his Facebook account.
    elsif session[:user_id].nil?  && authentication
      # We have the user but his session has expired or he logged out previously
      session[:user_id] = authentication.id
      authentication.update_attributes(:token => token, :expires => expires)
    else # NEW USER
        user = User.create(:username => user_data['username'],:first_name => user_data['first_name'],:last_name => user_data['last_name'])
        session[:user_id] = user.id
     authentication = Authentication.create do |authentication|
        authentication.provider = 'facebook'
        authentication.uid= user_data['id']
        authentication.expires = expires
        authentication.token = token
        authentication.name = user_data['name']
        authentication.link = user_data['link']
        # TWITTER authentication.secret = auth['credentials']['secret']
        authentication.user_id = session[:user_id]
        authentication.info = {:nickname => user_data['username'],
                                 :name => user_data['name']}
      end
    end 


  end





end
