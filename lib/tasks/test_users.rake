require 'resque/tasks'


desc "This tasks shows test user"
task :load_facebook_users => :environment do
  unless Rails.env.eql?('production')
    User.all.each { |user| user.destroy }

    http = Net::HTTP.new "graph.facebook.com", 443
    http.use_ssl = true
    
    # Asking for the app token
    response = http.request(Net::HTTP::Get.new("/oauth/access_token?client_id=#{ENV['FACEBOOK_KEY']}&&client_secret=#{ENV['FACEBOOK_SECRET']}&grant_type=client_credentials"))
    app_token = CGI.parse(response.body)["access_token"][0]

    # Asking for the users associated to this app. If there are no users we will create them
    response = http.request(Net::HTTP::Get.new("https://graph.facebook.com/#{ENV['FACEBOOK_KEY']}/accounts/test-users?access_token=#{app_token}"))
    app_users = MultiJson.decode response.body

    #creating the users in the database
    app_users['data'].each do |user|
      request  = Net::HTTP::Get.new "me?access_token=#{user['access_token']}"
      response = http.request request
      user_data = MultiJson.decode response.body
      User.create do |new_user|
        new_user.provider = 'facebook'
        new_user.uid= user_data['id']
        new_user.name= user_data['name']
        new_user.locale = user_data['locale']
        new_user.first_name= user_data['first_name']
        new_user.last_name= user_data['last_name']
        new_user.username= user_data['username']
        new_user.link= user_data['link']
        new_user.token = user['access_token'] #app_users['data'][0]['access_token']
      end

    end
  end

end
