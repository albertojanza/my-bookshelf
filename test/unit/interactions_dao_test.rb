require 'test_helper'
require 'facebook_user_seed'


class InteractionsDaoTest < ActiveSupport::TestCase

######################################
## THis task loads the Facebook users. It is cool to run it before passing the test to avoid to ask for the users before every test
## rake load_facebook_users RAILS_ENV=test --trace
## ruby -Itest test/unit/interactions_dao_test.rb -n test_Notifications_in_a_book_recommendation. 
############################################3

  def setup
    if User.count.eql? 0
      FacebookUserSeed.seed
    else 
      user = User.last
      begin 
        user.friends
      rescue User::TokenExpiration
        User.all.each {|user| user.destroy}
        FacebookUserSeed.seed
      end
    end
   Rails.cache.clear
   REDIS.flushdb
  end
 
  def teardown
    # as we are re-initializing @post before every test
    # setting it to nil here is not essential but I hope
    # you understand how you can use the teardown method
  end

  # Scenario: Three friends: Scorpions, Aeromisth and Bubury. 
  # Two of them mark a book as a read and then of them sends a recommendation of this book to the third one.
  test 'Notifications in a book recommendation.' do
    book = Book.find_by_asin '8498382548' 
    # These three guys are friends
    scorpions = User.find_by_uid '100003593065982'
    bunbury = User.find_by_uid '100003529976191'
    aerosmith = User.find_by_uid '100003533216061'

    # We check out that they don't have any notifications
    keys = REDIS.lrange("user:#{scorpions.id}:notifications", 0, 20)
    assert_equal keys, []
    count = REDIS.get "user:#{scorpions.id}:noti_count"
    assert_nil count
    keys = REDIS.lrange("user:#{aerosmith.id}:notifications", 0, 20)
    assert_equal keys, []
    count = REDIS.get "user:#{aerosmith.id}:noti_count"
    assert_nil count
    keys = REDIS.lrange("user:#{bunbury.id}:notifications", 0, 20)
    assert_equal keys, []
    count = REDIS.get "user:#{bunbury.id}:noti_count"
    assert_nil count

    # Scorpions marks the book as read
    experience1 = Experience.create do |experience|
        experience.book_id = book.id
        experience.user_id = scorpions.id
        experience.started_at = Time.now 
        experience.code = 0
    end

    # Bunbury marks the book as read
    experience2 = Experience.create do |experience|
        experience.book_id = book.id
        experience.user_id = bunbury.id
        experience.started_at = Time.now 
        experience.code = 0
    end
    # We check out that scorpions receives a notification 
    keys = REDIS.lrange("user:#{scorpions.id}:notifications", 0, 20)
    assert_equal keys.first, "experience:#{experience2.id}"
    count = REDIS.get "user:#{scorpions.id}:noti_count"
    assert_equal count, '1'
    
    # Bunbury sends a recommendation to aerosmith 
    experience3 = Experience.create do |experience|
        experience.book_id = book.id
        experience.user_id = aerosmith.id
        experience.recommender_id = bunbury.id
        experience.started_at = Time.now 
        experience.code = 0
    end

    # We check out that scorpions receives a notification of this recommendation since aerosmith has now the book in its bookcase.
    keys = REDIS.lrange("user:#{scorpions.id}:notifications", 0, 20)
    assert_equal keys.first, "experience:#{experience3.id}"
    count = REDIS.get "user:#{scorpions.id}:noti_count"
    assert_equal count, '2'

    # We check out that bunbury has this recommendation on it recommendation inbox.
    keys = REDIS.lrange("user:#{bunbury.id}:recommendations", 0, 20)
    assert_equal keys.first, "experience:#{experience3.id}"
    count = REDIS.get "user:#{bunbury.id}:reco_count"
    assert_equal count, '1'



  end


  test 'Notifications frome every friend.' do
    book = Book.find_by_asin '8498382548' 
    scorpions = User.find_by_uid '100003593065982'
    friends =  scorpions.friends.map{ |friend|  User.find_by_uid friend['id'] }
    # We check out that scorpions doesn't have any notifications
    keys = REDIS.lrange("user:#{scorpions.id}:notifications", 0, 20)
    assert_equal keys, []
    count = REDIS.get "user:#{scorpions.id}:noti_count"
    assert_nil count

      experience = Experience.create do |experience|
        experience.book_id = book.id
        experience.user_id = scorpions.id
        experience.started_at = Time.now 
        experience.code = 0
      end

    # Scorpions's friends just marked a book as read
    experiences = []
    friends.each do |friend|
      experiences << Experience.create do |experience|
        experience.book_id = book.id
        experience.user_id = friend.id
        experience.started_at = Time.now 
        experience.code = 0
      end
    end

    keys = REDIS.lrange("user:#{scorpions.id}:notifications", 0, 20)
    experiences.reverse.each_with_index { |ex,index| assert_equal keys[index],  "experience:#{ex.id}" } 
    count = REDIS.get "user:#{scorpions.id}:noti_count"
    assert_equal count.to_i, experiences.size


  end

  test 'All my friends receive a notification if they have read the book.' do
    book = Book.find_by_asin '8498382548' 
    scorpions = User.find_by_uid '100003593065982'
    friends =  scorpions.friends.map{ |friend|  User.find_by_uid friend['id'] }
    # This friend is not going to read any boook
    boring_friend = friends.pop

    # Scorpions's friends don't have any notification yet
    friends.each do |friend|
      keys = REDIS.lrange("user:#{friend.id}:notifications", 0, 20)
      assert_equal keys, []
      count = REDIS.get "user:#{friend.id}:noti_count"
      assert_nil count
    end

    # Scorpions's friends just marked a book as read
    friends.each do |friend|
      experience = Experience.create do |experience|
        experience.book_id = book.id
        experience.user_id = friend.id
        experience.started_at = Time.now 
        experience.code = 0
      end
    end

    # Now Scorpions marks the same book as read. And this has to trigger the notifications to those friends that have read the book.
    experience = Experience.create do |experience|
        experience.book_id = book.id
        experience.user_id = scorpions.id
        experience.started_at = Time.now 
        experience.code = 0
    end

    # We check out that the notifications were created
    friends.each do |friend|
      keys = REDIS.lrange("user:#{friend.id}:notifications", 0, 20)
      assert keys.size > 0
      count = REDIS.get "user:#{friend.id}:noti_count"
      assert count.to_i > 0
    end
    
    # We check out that the boring friend doesn't have any notifications
      keys = REDIS.lrange("user:#{boring_friend.id}:notifications", 0, 20)
      assert_equal keys, []
      count = REDIS.get "user:#{boring_friend.id}:noti_count"
      assert_nil count

  end


  # the users have names of music groups
  test "Friends receive the notification when a user starts reading abook that his friends have read" do
    book = Book.find_by_asin '8498382548' 
    scorpions = User.find_by_uid '100003593065982'
    friend = User.find_by_uid scorpions.friends.first['id']
    # The friend doesn't have any notification yet
    keys = REDIS.lrange("user:#{friend.id}:notifications", 0, 20)
    assert_equal keys, []
    count = REDIS.get "user:#{friend.id}:noti_count"
    assert_nil count

    experience = Experience.create do |experience|
        experience.book_id = book.id
        experience.user_id = friend.id
        experience.started_at = Time.now 
        experience.code = 0
    end
    # After creating an experience, the friend continues without having notification
    keys = REDIS.lrange("user:#{friend.id}:notifications", 0, 20)
    assert_equal keys, []
    count = REDIS.get "user:#{friend.id}:noti_count"
    assert_nil count

    experience = Experience.create do |experience|
        experience.book_id = book.id
        experience.user_id = scorpions.id
        experience.started_at = Time.now 
        experience.code = 0
    end

    #Now the friend got a notification
    keys = REDIS.lrange("user:#{friend.id}:notifications", 0, 20)
    assert_equal keys.first, "experience:#{experience.id}"
    assert_equal keys.size, 1
    count = REDIS.get "user:#{friend.id}:noti_count"
    assert_equal count, '1'
     

  end

end
