class SessionsController < ApplicationController

  def facebook_callback
    http = Net::HTTP.new "graph.facebook.com", 443
    request = Net::HTTP::Get.new "/oauth/access_token?client_id=#{ENV['FACEBOOK_KEY']}&redirect_uri=#{redirect_uri}&client_secret=#{ENV['FACEBOOK_SECRET']}&code=#{params[:code]}"
    http.use_ssl = true
    response = http.request request
    token = CGI.parse(response.body)["access_token"][0]

    request  = Net::HTTP::Get.new "me?access_token=#{token}"
    response = http.request request
    user_data = MultiJson.decode response.body

    authentication = Authentication.find_by_provider_and_uid('facebook', user_data['id'])
    if authentication && session[:user_id]  && !authentication.user.eql?(session[:user_id])
      # the user is logged with twitter and he is adding a facebook account. But he already has an user with the Facebook accountin the system.
      # We have to proceed to merge both user accounts
    elsif session[:user_id]  && authentication.nil?
      # The user is logged in with twitter and he is adding his Facebook account.
      
     authentication = Authentication.create do |authentication|
        authentication.provider = 'facebook'
        authentication.uid= user_data['id']
        authentication.token = token
        # TWITTER authentication.secret = auth['credentials']['secret']
        authentication.user_id = session[:user_id]
        authentication.info = {:nickname => user_data['username'],
                                 :name => user_data['name']}
      end
    elsif session[:user_id].nil?  && authentication
      # We have the user but his session has expired or he logged out previously
      session[:user_id] = authentication.id
    else # NEW USER
        user = User.create(:username => user_data['username'],:first_name => user_data['first_name'],:last_name => user_data['last_name'])
        session[:user_id] = user.id
     authentication = Authentication.create do |authentication|
        authentication.provider = 'facebook'
        authentication.uid= user_data['id']
        authentication.token = token
        # TWITTER authentication.secret = auth['credentials']['secret']
        authentication.user_id = session[:user_id]
        authentication.info = {:nickname => user_data['username'],
                                 :name => user_data['name']}
      end
    end 


    render :callback
  end

  # This action redirects to facebook to ask for permission.
  # TODO posible refactorization to do this from the navigator, it is not necesary to have our server as a middle man
  def facebook_permission
    redirect_to "https://graph.facebook.com/oauth/authorize?client_id=#{ENV['FACEBOOK_KEY']}&redirect_uri=#{facebook_callback_url}&scope=offline_access%2Cread_stream"
  end



  def destroy
    session[:user_id] = nil
    redirect_to root_url, :notice => "You have been logged out."
  end



private

def redirect_uri  
  uri = URI.parse(request.url)  
  uri.path = '/facebook/callback'  
  uri.query = nil  
  uri.to_s  
end  

end
