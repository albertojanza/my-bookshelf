# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
require 'cgi'


#-------------------------------------------------------------------------------  
# Books
#-------------------------------------------------------------------------------  
  science_fiction = []
  history = []
  cook = []
  other = []
  ingeneering = []
  
  science_fiction<<  Book.find_by_asin('0486411095') # Bram Stoker Drakula
  # Stephen king it
  science_fiction << Book.find_by_asin('0451169514')
  science_fiction << Book.find_by_asin('0671039741')  #Salem's Lot
  science_fiction << Book.find_by_asin('0451196716')  #the long walk
  science_fiction << Book.find_by_asin('0452284694')  #the gunslinger
  science_fiction << Book.find_by_asin('1451678606')  #bag of bones
  # Dean koontz
  science_fiction << Book.find_by_asin('0425243273')  #Midnight
  science_fiction << Book.find_by_asin('0553807714')  #77 shadow street
  science_fiction << Book.find_by_asin('0553807722')  #What the night knows
  science_fiction << Book.find_by_asin('042523360X')  #Lightning
  science_fiction << Book.find_by_asin('0553807749')  #odd apocalypse
  science_fiction << Book.find_by_asin('0425221806')  #Strangers
  
  # Stephen king it
  science_fiction << Book.find_by_asin('B006W3ZNRE')  #Full darks, no stars

  #history books
  history << Book.find_by_asin('0143035738')  #The second world war john keegan
  history << Book.find_by_asin('0061228591')  #The storm of the war Robert
  history << Book.find_by_asin('1463704976')  # The story of the common soldier of army life in the civil war
  history << Book.find_by_asin('B002XULZZ4')  # The triumph of caesar
  history << Book.find_by_asin('0812976614')  # Prehistory

  # cook books 
  cook << Book.find_by_asin('3842487177')  #How to cook fish 
  cook << Book.find_by_asin('B001RF3U9U')  # How to cook
  cook << Book.find_by_asin('0764578650')  # How to cook everything 

  # Other 
  other << Book.find_by_asin('1594771766') # Iboga
  science_fiction << Book.find_by_asin('0060731338') # Steven Levit Freakonomics
   
  # Engineering
  ingeneering << Book.find_by_asin('1934356549') #David Heinemeer Agile Web Development with Ruby on Rails

 
#-------------------------------------------------------------------------------  
# Users 
#-------------------------------------------------------------------------------  
  
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


#-------------------------------------------------------------------------------  
# Users 
#-------------------------------------------------------------------------------  

  users = User.all

  # The first user reads science_fiction
  science_fiction[0..(science_fiction.size - 2)].each do |book|
     Experience.create do |experience|
        experience.adventure_id = book.adventure.id
        experience.user_id = users[0].id
      end
  end 
 science_fiction[(science_fiction.size - 2)..science_fiction.size].each do |book|
     Experience.create do |experience|
        experience.adventure_id = book.adventure.id
        experience.user_id = users[0].id
        experience.started_at = Time.now
        experience.code = 1
      end
  end
  # The third user reads science_fiction too
  science_fiction[0..(science_fiction.size - 1)].each do |book|
     Experience.create do |experience|
        experience.adventure_id = book.adventure.id
        experience.user_id = users[2].id
      end
  end 
 science_fiction[(science_fiction.size - 1)..science_fiction.size].each do |book|
     Experience.create do |experience|
        experience.adventure_id = book.adventure.id
        experience.user_id = users[2].id
        experience.started_at = Time.now
        experience.code = 1
      end
  end
  # The second guy reads history and cook books
  history.each do |book|
     Experience.create do |experience|
        experience.adventure_id = book.adventure.id
        experience.user_id = users[1].id
      end
  end 
  cook.each do |book|
     Experience.create do |experience|
        experience.adventure_id = book.adventure.id
        experience.user_id = users[1].id
      end
  end 
  #Everyone reads ingeneering books
  ingeneering.each do |book|
     Experience.create do |experience|
        experience.adventure_id = book.adventure.id
        experience.user_id = users[0].id
      end
  end 
  ingeneering.each do |book|
     Experience.create do |experience|
        experience.adventure_id = book.adventure.id
        experience.user_id = users[1].id
      end
  end 
  ingeneering.each do |book|
     Experience.create do |experience|
        experience.adventure_id = book.adventure.id
        experience.user_id = users[2].id
      end
  end 
  #Only the firs guy reads other books
  other.each do |book|
     Experience.create do |experience|
        experience.adventure_id = book.adventure.id
        experience.user_id = users[0].id
      end
  end 
