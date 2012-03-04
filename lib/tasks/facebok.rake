require 'active_record'
require 'cgi'


desc "This tasks shows test user"
task :show_users => :environment do
    http = Net::HTTP.new "graph.facebook.com", 443
    http.use_ssl = true
    response = http.request(Net::HTTP::Get.new("/oauth/access_token?client_id=#{ENV['FACEBOOK_KEY']}&&client_secret=#{ENV['FACEBOOK_SECRET']}&grant_type=client_credentials"))
    app_token = CGI.parse(response.body)["access_token"][0]
    # Asking for the users associated to this app. If there are no users we will create them
    response = http.request(Net::HTTP::Get.new("https://graph.facebook.com/#{ENV['FACEBOOK_KEY']}/accounts/test-users?access_token=#{app_token}"))
    app_users = MultiJson.decode response.body
    puts "Using these urls you can log in Facebook"
    puts "Test users of the app #{ENV['FACEBOOK_KEY']}:"
    app_users["data"].each do |user| 
      puts "Test user id: #{user['id']}  login_url: #{user['login_url']}"
    end

end

desc "This tasks grab the test users from other app"
task :import_users => :environment do
    http = Net::HTTP.new "graph.facebook.com", 443
    http.use_ssl = true

    # Asking for the token of the app owner
    response = http.request(Net::HTTP::Get.new("/oauth/access_token?client_id=#{ENV['FACEBOOK_KEY']}&&client_secret=#{ENV['FACEBOOK_SECRET']}&grant_type=client_credentials"))
    app_owner_token = CGI.parse(response.body)["access_token"][0]

    # Asking for the token of the app 
    response = http.request(Net::HTTP::Get.new("/oauth/access_token?client_id=#{ENV['OTHER_FACEBOOK_KEY']}&&client_secret=#{ENV['OTHER_FACEBOOK_SECRET']}&grant_type=client_credentials"))
    app_token = CGI.parse(response.body)["access_token"][0]

    response = http.request(Net::HTTP::Get.new("https://graph.facebook.com/#{ENV['FACEBOOK_KEY']}/accounts/test-users?access_token=#{app_owner_token}"))
    app_users = MultiJson.decode response.body

    app_users["data"].each do |user|
      response = http.request(Net::HTTP::Get.new("https://graph.facebook.com/#{ENV['OTHER_FACEBOOK_KEY']}/accounts/test-users?installed=true&permissions=publish_actions&uid=#{user['id']}&owner_access_token=#{app_owner_token}&access_token=#{app_token}&method=post"))
      MultiJson.decode response.body
    end
end

desc "this task shows the urls of three test facebook users associated with this facebook app. if the app doesnt have any test user this task will create three facebok test users in the case that they dont exist."
task :create_users => :environment do

    http = Net::HTTP.new "graph.facebook.com", 443
    http.use_ssl = true
    
    # Asking for the app token
    response = http.request(Net::HTTP::Get.new("/oauth/access_token?client_id=#{ENV['FACEBOOK_KEY']}&&client_secret=#{ENV['FACEBOOK_SECRET']}&grant_type=client_credentials"))
    app_token = CGI.parse(response.body)["access_token"][0]

    # Asking for the users associated to this app. If there are no users we will create them
    response = http.request(Net::HTTP::Get.new("https://graph.facebook.com/#{ENV['FACEBOOK_KEY']}/accounts/test-users?access_token=#{app_token}"))
    app_users = MultiJson.decode response.body
    if app_users["data"].size < 20
      (20 - app_users["data"].size).times { http.request(Net::HTTP::Get.new("https://graph.facebook.com/#{ENV['FACEBOOK_KEY']}/accounts/test-users?installed=true&name=messireads&permissions=publish_actions&method=post&access_token=#{app_token}")) }
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
    names = ['scorpions','aerosmith','ironmaiden','helloween','acdc','bon jovi','metallica','seether','sober', 'bunbury','la oreja de van gogh','celtascortos','elcantodeloco','losrodriguez','lospiratas','melendi','luzcasal','amistades peligrosas']

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

    # scorpions is friend of every heavy and bunbury
    app_users['data'][1..9].each_with_index do |user,i| 
      request = Net::HTTP::Post.new "/#{user['id']}/friends/#{app_users['data'][0]['id']}"
      request.set_form_data({'method' => 'post', 'access_token' => app_users['data'][0]['access_token']})
      http.request(request)
      request = Net::HTTP::Post.new "/#{app_users['data'][0]['id']}/friends/#{user['id']}"
      request.set_form_data({'method' => 'post', 'access_token' => user['access_token']})
      http.request(request)
    end

    # aeromisth is friend of every heavy and bunbury
    app_users['data'][2..9].each_with_index do |user,i| 
      request = Net::HTTP::Post.new "/#{user['id']}/friends/#{app_users['data'][1]['id']}"
      request.set_form_data({'method' => 'post', 'access_token' => app_users['data'][1]['access_token']})
      http.request(request)
      request = Net::HTTP::Post.new "/#{app_users['data'][1]['id']}/friends/#{user['id']}"
      request.set_form_data({'method' => 'post', 'access_token' => user['access_token']})
      http.request(request)
    end




end





desc "This tasks deletes every test facebook user associated with this app."
task :delete_users => :environment do
    other_app_keys = {'176942332409589' => '2eef538571773947889a8513cc564360','216683321695985' => '6214174b68718c5146a6ab2b74b042bf','272512669482455' => '5a096c006ad0a0139a8187abeaebe455'}

    http = Net::HTTP.new "graph.facebook.com", 443
    http.use_ssl = true
    
    # Asking for the app token
    response = http.request(Net::HTTP::Get.new("/oauth/access_token?client_id=#{ENV['FACEBOOK_KEY']}&&client_secret=#{ENV['FACEBOOK_SECRET']}&grant_type=client_credentials"))
    app_token = CGI.parse(response.body)["access_token"][0]

    # Asking for the users associated to this app. If there are no users we will create them
    response = http.request(Net::HTTP::Get.new("https://graph.facebook.com/#{ENV['FACEBOOK_KEY']}/accounts/test-users?access_token=#{app_token}"))
    app_users = MultiJson.decode response.body

    puts "Removing test users of the app #{ENV['FACEBOOK_KEY']}:"
    app_users['data'].each do |user| 
      response = http.request(Net::HTTP::Get.new("https://graph.facebook.com/#{user['id']}?method=delete&access_token=#{app_token}"))
      message = MultiJson.decode response.body
      if message['error'] && message['error']['code'].eql?(2903)
        response = http.request(Net::HTTP::Get.new("https://graph.facebook.com/#{ENV['FACEBOOK_KEY']}/accounts/test-users?uid=#{user['id']}&method=delete&access_token=#{app_token}"))
        puts "The user #{user['id']} was deleted from this app, but he still exists because it is associated to another app"
      end
    end


end


desc "This task destroy a test user. To destroy an user, we have to remove it first for every app in which it is associated. We need the API keys of the apps."
# Expeted parameter user_id
# rake user_apps user_id=100003576790676 --trace
task :destroy_user => :environment do
    other_app_keys = {'176942332409589' => '2eef538571773947889a8513cc564360','216683321695985' => '6214174b68718c5146a6ab2b74b042bf','272512669482455' => '5a096c006ad0a0139a8187abeaebe455'}

    user_id = ENV['user_id']

    http = Net::HTTP.new "graph.facebook.com", 443
    http.use_ssl = true

    # Asking for the app token
    response = http.request(Net::HTTP::Get.new("/oauth/access_token?client_id=#{ENV['FACEBOOK_KEY']}&&client_secret=#{ENV['FACEBOOK_SECRET']}&grant_type=client_credentials"))
    app_token = CGI.parse(response.body)["access_token"][0]

    response = http.request(Net::HTTP::Get.new("https://graph.facebook.com/#{user_id}?method=delete&access_token=#{app_token}"))
    unless response.class.eql? Net::HTTPOK

      message = MultiJson.decode response.body 
      if message['error'] && message['error']['code'].eql?(2903)
        response = http.request(Net::HTTP::Get.new("https://graph.facebook.com/#{user_id}/ownerapps?access_token=#{app_token}"))
        apps = MultiJson.decode response.body
        apps['data'].each do |app| 
          unless app['id'].eql?(ENV['FACEBOOK_KEY'])
            if other_app_keys[app['id']]
                puts "Removing the user  #{user_id} from the app #{app['id']}"
                response = http.request(Net::HTTP::Get.new("/oauth/access_token?client_id=#{app['id']}&&client_secret=#{other_app_keys[app['id']]}&grant_type=client_credentials"))
                other_app_token = CGI.parse(response.body)["access_token"][0]
                response = http.request(Net::HTTP::Get.new("https://graph.facebook.com/#{app['id']}/accounts/test-users?uid=#{user_id}&method=delete&access_token=#{other_app_token}"))
            else
                puts "The user with the id #{user_id} is associated with other apps, to remove it"
            end
          end
        end
        response = http.request(Net::HTTP::Get.new("https://graph.facebook.com/#{user_id}?method=delete&access_token=#{app_token}"))
      end
    end
#"https://graph.facebook.com/APP_ID/accounts/test-users?uid=TEST_ACCOUNT_ID&access_token=APPLICATION_ACCESS_TOKEN&method=delete"
#When only one app remains you can delete the test account using :
#"https://graph.facebook.com/TEST_ACCOUNT_ID?method=delete&access_token=TEST_ACCOUNT_ACCESS_TOKEN"
# THE one
#response = http.request(Net::HTTP::Get.new("https://graph.facebook.com/216683321695985/accounts/test-users?uid=100003576790676&method=delete&access_token=#{app_token}"))


end





desc "Apps associated to a test user"
# Expeted parameter user_id
# rake user_apps user_id=100003576790676 --trace
task :user_apps => :environment do
    http = Net::HTTP.new "graph.facebook.com", 443
    http.use_ssl = true
    
    # Asking for the app token
    response = http.request(Net::HTTP::Get.new("/oauth/access_token?client_id=#{ENV['FACEBOOK_KEY']}&&client_secret=#{ENV['FACEBOOK_SECRET']}&grant_type=client_credentials"))
    app_token = CGI.parse(response.body)["access_token"][0]
    response = http.request(Net::HTTP::Get.new("https://graph.facebook.com/#{ENV['user_id']}/ownerapps?access_token=#{app_token}"))
    apps = MultiJson.decode response.body
    apps['data'].each do |app| 
      puts "canvas_name: #{app['canvas_name']} app_id #{app['id']}"
    end

end


#Test user id: 100003593065982 scorpions_acbbcko_scorpions@tfbnw.net
#Test user id: 100003533216061 aerosmith_ddtzqmc_aerosmith@tfbnw.net
#Test user id: 100003571136068 
#Test user id: 100003568525827 
#Test user id: 100003544705905 
#Test user id: 100003605762907 
#Test user id: 100003612872856 
#Test user id: 100003577706094 
#Test user id: 100003611102868 sober_onqyfsq_sober@tfbnw.net 
#Test user id: 100003529976191  
#Test user id: 100003618332848 bunbury_qukrucn_bunbury@tfbnw.net 
#Test user id: 100003600212912  
#Test user id: 100003646681574 
#Test user id: 100003530845925 
#Test user id: 100003569725802  
#Test user id: 100003614912874 
#Test user id: 100003543055764  
#Test user id: 100003542425815  
#Test user id: 100003569755950  
#Test user id: 100003613982751



