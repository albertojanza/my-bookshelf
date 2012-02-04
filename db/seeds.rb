# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
require 'cgi'

  read_books = []
  current_books = []
  
  # Stephen king it
  read_books << Book.find_by_asin('0451169514')

  # Iboga
  read_books << Book.find_by_asin('1594771766')

  # Stephen king Salem's Lot
  current_books << Book.find_by_asin('0671039741')

  # Steven Levit Freakonomics 
  read_books << Book.find_by_asin('0060731338')

  # Bram Stoker Drakula 
  current_books <<  Book.find_by_asin('0486411095')

  #David Heinemeer Agile Web Development with Ruby on Rails
  current_books << Book.find_by_asin('0486411095')

  user = User.create(:username => 'ritalacantaora',:first_name => 'rita',:last_name => 'lacantaora')

  read_books.each do |book|
     Experience.create do |experience|
        experience.adventure_id = book.adventure.id
        experience.user_id = user.id
      end
  end 
  current_books.each do |book|
     Experience.create do |experience|
        experience.adventure_id = book.adventure.id
        experience.user_id = user.id
        experience.started_at = Time.now
      end
  end
  
  # Friends
  #friend1 = User.find_by_username 'albertojanza' 
  #friend1 = User.find_by_username 'albertojanza' 
  
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
      user = User.create(:username => user_data['username'],:first_name => user_data['first_name'],:last_name => user_data['last_name'])
      authentication = Authentication.create do |authentication|
        authentication.provider = 'facebook'
        authentication.uid= user_data['id']
        authentication.token = app_users['data'][0]['access_token']
        # TWITTER authentication.secret = auth['credentials']['secret']
        authentication.user_id = user.id
        authentication.info = {:nickname => user_data['username'],
                                 :name => user_data['name']}
      end

    end
