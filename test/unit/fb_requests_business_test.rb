require 'test_helper'
require 'facebook_user_seed'
require 'facebook_api'


class InteractionsDaoTest < ActiveSupport::TestCase

######################################
## THis task loads the Facebook users. It is cool to run it before passing the test to avoid to ask for the users before every test
## rake load_facebook_users RAILS_ENV=test --trace
## ruby -Itest test/unit/interactions_dao_test.rb -n test_FbRequests_in_a_book_recommendation. 
############################################3

  def setup
   Rails.cache.clear
   REDIS.flushdb
  end
 
  def teardown
    # as we are re-initializing @post before every test
    # setting it to nil here is not essential but I hope
    # you understand how you can use the teardown method
  end


  # Scenario: All friends of the user Scorpions mark a book, that Scorpions has read, as read. So Scorpions should receive an app-generated request per every friend.
  test 'Facebook app-generated request.' do
    book = Book.find_by_asin '8498382548' 
    scorpions = User.find_by_uid '100003593065982'
    FacebookApi.delete_all_request(scorpions.uid,scorpions.token)

    # We check out that scorpions doesn't have any facebook request
    assert_equal [], FbRequestsBusiness.get_facebook_requests(scorpions.id)
    assert_nil FbRequestsBusiness.fb_requests_count(scorpions.id)

    # Scorpions marks the book as read
    experience1 = Experience.create do |experience|
        experience.book_id = book.id
        experience.user_id = scorpions.id
        experience.started_at = Time.now 
        experience.code = 0
    end
    ExperiencesBusiness.create_experience(experience1,'APP-GENERATED')


    friends =  scorpions.friends.map{ |friend|  User.find_by_uid friend['id'] }

    friends.each do |friend|
      experience2 = Experience.create do |experience|
        experience.book_id = book.id
        experience.user_id = friend.id
        experience.started_at = Time.now 
        experience.code = 0
      end
      ExperiencesBusiness.create_experience(experience2,'APP-GENERATED')
    end

    assert_equal  friends.size.to_s, FbRequestsBusiness.fb_requests_count(scorpions.id)

  end

  # Testing the method remove_requests. 
  # Scenario every friend of scorpions reads a book that he has read and them he receives a facebook_request per every friend
  test 'remove_facebook_requests.' do
    scorpions = User.find_by_uid '100003593065982'
    bunbury = User.find_by_uid '100003529976191'
    aerosmith = User.find_by_uid '100003533216061'
    helloween = User.find_by_uid '100003568525827'
    acdc = User.find_by_uid '100003544705905'
    ironmaiden = User.find_by_uid '100003571136068'
    book = Book.find_by_asin '8498382548' 
    users = [scorpions,bunbury,aerosmith,helloween,acdc,ironmaiden] 
    experiences = []
    
    # We remove posible request that our test users can have
    users.each { |user| FacebookApi.delete_all_request(user.uid,user.token) }
  
    users.each do |user| 
      # Scorpions marks the book as read
      experience = Experience.create do |experience|
          experience.book_id = book.id
          experience.user_id = user.id
          experience.started_at = Time.now 
          experience.code = 0
      end
      ExperiencesBusiness.create_experience(experience,'APP-GENERATED')
      experiences << experience
    end

    FbRequestsBusiness.remove_requests scorpions.token, scorpions.id
    requests = FacebookApi.user_get_all_request scorpions.uid
    assert requests.empty?

  end

  # Testing the methods get_facebook_request and get_facebook_requets
  # Scenario every friend of scorpions reads a book that he has read and them he receives a facebook_request per every friend
  test 'get_facebook_requests.' do
    scorpions = User.find_by_uid '100003593065982'
    bunbury = User.find_by_uid '100003529976191'
    aerosmith = User.find_by_uid '100003533216061'
    helloween = User.find_by_uid '100003568525827'
    acdc = User.find_by_uid '100003544705905'
    ironmaiden = User.find_by_uid '100003571136068'
    book = Book.find_by_asin '8498382548' 
    users = [scorpions,bunbury,aerosmith,helloween,acdc,ironmaiden] 
    experiences = []
    
    # We remove posible request that our test users can have
    users.each { |user| FacebookApi.delete_all_request(user.uid,user.token) }
  
    users.each do |user| 
      # Scorpions marks the book as read
      experience = Experience.create do |experience|
          experience.book_id = book.id
          experience.user_id = user.id
          experience.started_at = Time.now 
          experience.code = 0
      end
      ExperiencesBusiness.create_experience(experience,'APP-GENERATED')
      experiences << experience
    end

   
    requests = FacebookApi.user_get_all_request scorpions.uid
    keys = REDIS.smembers("user:#{scorpions.id}:fb_requests")
    requests.each { |request| assert keys.include?(request['id'])}

    fb_requests = FbRequestsBusiness.get_facebook_requests(scorpions.id)
    assert_equal fb_requests.size, 5 

  end


  # Scenario: Three friends: Scorpions, Aeromisth and Bubury. 
  # Two of them mark a book as a read and then one of them sends a recommendation of this book to the third one.
  test 'App-generated requests in a book recommendation.' do
    book = Book.find_by_asin '8498382548' 
    # These three guys are friends
    scorpions = User.find_by_uid '100003593065982'
    bunbury = User.find_by_uid '100003529976191'
    aerosmith = User.find_by_uid '100003533216061'

    # We check out that they don't have any requests
    assert_nil FbRequestsBusiness.fb_requests_count(scorpions.id)
    assert_equal FbRequestsBusiness.get_facebook_requests(scorpions.id), []
    assert_nil FbRequestsBusiness.fb_requests_count(aerosmith.id)
    assert_equal FbRequestsBusiness.get_facebook_requests(aerosmith.id), []
    assert_nil FbRequestsBusiness.fb_requests_count(bunbury.id)
    assert_equal FbRequestsBusiness.get_facebook_requests(bunbury.id), []

    # Scorpions marks the book as read
    experience1 = Experience.create do |experience|
        experience.book_id = book.id
        experience.user_id = scorpions.id
        experience.started_at = Time.now 
        experience.code = 0
    end
    ExperiencesBusiness.create_experience(experience1,'APP-GENERATED')

    # Bunbury marks the book as read
    experience2 = Experience.create do |experience|
        experience.book_id = book.id
        experience.user_id = bunbury.id
        experience.started_at = Time.now 
        experience.code = 0
    end
    ExperiencesBusiness.create_experience(experience2,'APP-GENERATED')
    # We check out that scorpions receives a facebook request
    assert_equal FbRequestsBusiness.fb_requests_count(scorpions.id), '1'
    assert_equal FbRequestsBusiness.get_facebook_requests(scorpions.id).size, 1
    assert_nil FbRequestsBusiness.fb_requests_count(aerosmith.id)
    assert_equal FbRequestsBusiness.get_facebook_requests(aerosmith.id), []
    assert_nil FbRequestsBusiness.fb_requests_count(bunbury.id)
    assert_equal FbRequestsBusiness.get_facebook_requests(bunbury.id), []

    # Bunbury sends a recommendation to aerosmith 
    experience3 = Experience.create do |experience|
        experience.book_id = book.id
        experience.user_id = aerosmith.id
        experience.recommender_id = bunbury.id
        experience.started_at = Time.now 
        experience.code = 3
    end
    ExperiencesBusiness.create_experience(experience3,'APP-GENERATED')

    # We check out that scorpions receives a notification of this recommendation since aerosmith has now the book in its bookcase.

    # We check out that scorpions doesn't receives a new notification 
    assert_equal FbRequestsBusiness.fb_requests_count(scorpions.id), '1'
    assert_equal FbRequestsBusiness.get_facebook_requests(scorpions.id).size, 1
    assert_nil FbRequestsBusiness.fb_requests_count(bunbury.id)
    assert_equal FbRequestsBusiness.get_facebook_requests(bunbury.id), []
    # We check out that Aerosmith has received a app-generated request with the recommendation
    assert_equal FbRequestsBusiness.fb_requests_count(aerosmith.id), '1'
    assert_equal FbRequestsBusiness.get_facebook_requests(aerosmith.id).size, 1 

  end



end
