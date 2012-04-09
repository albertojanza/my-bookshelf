class FacebookApi

  def self.send_request(uid,message, data)
    http = Net::HTTP.new "graph.facebook.com", 443
    http.use_ssl = true

    # Asking for the app token
    response = http.request(Net::HTTP::Get.new("/oauth/access_token?client_id=#{ENV['FACEBOOK_KEY']}&client_secret=#{ENV['FACEBOOK_SECRET']}&grant_type=client_credentials"))
    app_token = CGI.parse(response.body)["access_token"][0]

    post =  "/#{uid}/apprequests?"
    request = Net::HTTP::Post.new post
    request.set_form_data({ 'message' => message,'data' => data, 'access_token' => app_token})
    response = http.request request
    data = MultiJson.decode(response.body)

  end

  def self.get_request(request_id)
    http = Net::HTTP.new "graph.facebook.com", 443
    http.use_ssl = true

    # Asking for the app token
    response = http.request(Net::HTTP::Get.new("/oauth/access_token?client_id=#{ENV['FACEBOOK_KEY']}&client_secret=#{ENV['FACEBOOK_SECRET']}&grant_type=client_credentials"))
    app_token = CGI.parse(response.body)["access_token"][0]

    response = http.request(Net::HTTP::Get.new("https://graph.facebook.com/#{request_id}?access_token=#{app_token}"))
    data = MultiJson.decode(response.body)

    end

  def self.delete_request(request_id,user_token)
    http = Net::HTTP.new "graph.facebook.com", 443
    http.use_ssl = true

    response = http.request(Net::HTTP::Get.new("https://graph.facebook.com/#{request_id}?method=delete&access_token=#{user_token}"))

    #data = MultiJson.decode(response.body)
  end

  def self.user_get_all_request(uid)
    http = Net::HTTP.new "graph.facebook.com", 443
    http.use_ssl = true

    # Asking for the app token
    response = http.request(Net::HTTP::Get.new("/oauth/access_token?client_id=#{ENV['FACEBOOK_KEY']}&client_secret=#{ENV['FACEBOOK_SECRET']}&grant_type=client_credentials"))
    app_token = CGI.parse(response.body)["access_token"][0]

    response = http.request(Net::HTTP::Get.new("https://graph.facebook.com/#{uid}/apprequests?access_token=#{app_token}"))
    data = MultiJson.decode(response.body)
    data['data']
  end

  def self.delete_all_request(uid,user_token)
    http = Net::HTTP.new "graph.facebook.com", 443
    http.use_ssl = true

    # Asking for the app token
    response = http.request(Net::HTTP::Get.new("/oauth/access_token?client_id=#{ENV['FACEBOOK_KEY']}&client_secret=#{ENV['FACEBOOK_SECRET']}&grant_type=client_credentials"))
    app_token = CGI.parse(response.body)["access_token"][0]

    response = http.request(Net::HTTP::Get.new("https://graph.facebook.com/#{uid}/apprequests?access_token=#{app_token}"))
    data = MultiJson.decode(response.body)
    data['data'].each do |request| 
      self.delete_request(request['id'],user_token)
    end 
  end

end 
