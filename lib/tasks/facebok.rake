require 'active_record'
require 'cgi'

desc "This task shows the urls of three test facebook users associated with this Facebook app. If the app doesnt have any test user this task will create three facebok test users in the case that they dont exist."
task :create_users => :environment do

    http = Net::HTTP.new "graph.facebook.com", 443
    http.use_ssl = true
    
    # Asking for the app token
    response = http.request(Net::HTTP::Get.new("/oauth/access_token?client_id=#{ENV['FACEBOOK_KEY']}&&client_secret=#{ENV['FACEBOOK_SECRET']}&grant_type=client_credentials"))
    app_token = CGI.parse(response.body)["access_token"][0]

    # Asking for the users associated to this app. If there are no users we will create them
    response = http.request(Net::HTTP::Get.new("https://graph.facebook.com/#{ENV['FACEBOOK_KEY']}/accounts/test-users?access_token=#{app_token}"))
    app_users = MultiJson.decode response.body
    if app_users["data"].size < 3
      (3 - app_users["data"].size).times { http.request(Net::HTTP::Get.new("https://graph.facebook.com/#{ENV['FACEBOOK_KEY']}/accounts/test-users?installed=true&name=messireads&permissions=read_stream&method=post&access_token=#{app_token}")) }
      response = http.request(Net::HTTP::Get.new("https://graph.facebook.com/#{ENV['FACEBOOK_KEY']}/accounts/test-users?access_token=#{app_token}"))
      app_users = MultiJson.decode response.body
    end
    puts "Using these urls you can log in Facebook"
    app_users["data"].each do |user| 
      puts "login_url: #{user['login_url']}"
    end

end

desc "This task changes the password of the facebook test users associated to this app"
task :change_names => :environment do
    names = ['ironmaiden','bunbury','heroes']

    http = Net::HTTP.new "graph.facebook.com", 443
    http.use_ssl = true

    response = http.request(Net::HTTP::Get.new("/oauth/access_token?client_id=#{ENV['FACEBOOK_KEY']}&&client_secret=#{ENV['FACEBOOK_SECRET']}&grant_type=client_credentials"))
    app_token = CGI.parse(response.body)["access_token"][0]

    response = http.request(Net::HTTP::Get.new("https://graph.facebook.com/#{ENV['FACEBOOK_KEY']}/accounts/test-users?access_token=#{app_token}"))
    app_users = MultiJson.decode response.body

    # Changing the user name and password of the test users
    result = []
    app_users["data"].each_with_index do |user,index|

      request = Net::HTTP::Post.new "/#{user['id']}"
      request.set_form_data({'password' => ENV['HTTP_PASSWORD'],'name' => names[index], 'method' => 'post', 'access_token' => app_token })
    
      result << http.request(request)
    end
    #result = http.request Net::HTTP::Post.new("https://graph.facebook.com/#{user['id']}?password=#{ENV['HTTP_PASSWORD']}&name=zipizape_#{names[index]}&method=post&access_token=#{app_token}")

    response = http.request(Net::HTTP::Get.new("https://graph.facebook.com/#{ENV['FACEBOOK_KEY']}/accounts/test-users?access_token=#{app_token}"))
    app_users = MultiJson.decode response.body
    puts "Using these urls you can log in Facebook"
    app_users["data"].each do |user| 
      puts "login_url: #{user['login_url']}"
    end
end

desc "This task makes friend connections between the facebook test users"
task :make_friends => :environment do
    names = ['ironmaiden','bunbury','heroes']

    http = Net::HTTP.new "graph.facebook.com", 443
    http.use_ssl = true

    response = http.request(Net::HTTP::Get.new("/oauth/access_token?client_id=#{ENV['FACEBOOK_KEY']}&&client_secret=#{ENV['FACEBOOK_SECRET']}&grant_type=client_credentials"))
    app_token = CGI.parse(response.body)["access_token"][0]

    response = http.request(Net::HTTP::Get.new("https://graph.facebook.com/#{ENV['FACEBOOK_KEY']}/accounts/test-users?access_token=#{app_token}"))
    app_users = MultiJson.decode response.body


    # Ironmaiden is friend of heroes
    request = Net::HTTP::Post.new "/#{app_users['data'][0]['id']}/friends/#{app_users['data'][2]['id']}"
    request.set_form_data({'method' => 'post', 'access_token' => app_users['data'][0]['access_token']})
    http.request(request)
    request = Net::HTTP::Post.new "/#{app_users['data'][2]['id']}/friends/#{app_users['data'][0]['id']}"
    request.set_form_data({'method' => 'post', 'access_token' => app_users['data'][2]['access_token']})
     http.request(request)

    # Bunbury is friend of heroes
    request = Net::HTTP::Post.new "/#{app_users['data'][1]['id']}/friends/#{app_users['data'][2]['id']}"
    request.set_form_data({'method' => 'post', 'access_token' => app_users['data'][1]['access_token']})
    http.request(request)
    request = Net::HTTP::Post.new "/#{app_users['data'][2]['id']}/friends/#{app_users['data'][1]['id']}"
    request.set_form_data({'method' => 'post', 'access_token' => app_users['data'][2]['access_token']})
    http.request(request)

end





desc "This tasks deletes every test facebook user associated with this app."
task :delete_users => :environment do

    http = Net::HTTP.new "graph.facebook.com", 443
    http.use_ssl = true
    
    # Asking for the app token
    response = http.request(Net::HTTP::Get.new("/oauth/access_token?client_id=#{ENV['FACEBOOK_KEY']}&&client_secret=#{ENV['FACEBOOK_SECRET']}&grant_type=client_credentials"))
    app_token = CGI.parse(response.body)["access_token"][0]

    # Asking for the users associated to this app. If there are no users we will create them
    response = http.request(Net::HTTP::Get.new("https://graph.facebook.com/#{ENV['FACEBOOK_KEY']}/accounts/test-users?access_token=#{app_token}"))
    app_users = MultiJson.decode response.body
    if app_users["data"].size < 3
      (3 - app_users["data"].size).times { http.request(Net::HTTP::Get.new("https://graph.facebook.com/#{ENV['FACEBOOK_KEY']}/accounts/test-users?installed=true&name=messireads&permissions=read_stream&method=post&access_token=#{app_token}")) }
      response = http.request(Net::HTTP::Get.new("https://graph.facebook.com/#{ENV['FACEBOOK_KEY']}/accounts/test-users?access_token=#{app_token}"))
      app_users = MultiJson.decode response.body
    end
    puts "Using these urls you can log in Facebook"
    app_users["data"].each do |user| 
      puts "login_url: #{user['login_url']}"
    end

end
#ironmaiden_tzslbif_ironmaiden@tfbnw.net
#bunbury_kkugoqc_bunbury@tfbnw.net
#heroes_trknowe_heroes@tfbnw.net
