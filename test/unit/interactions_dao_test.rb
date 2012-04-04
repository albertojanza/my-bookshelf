require 'test_helper'
require 'facebook_user_seed'


class InteractionsDaoTest < ActiveSupport::TestCase

  # called before every single test
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
   REDIS.flushdb
  end
 
  # called after every single test
  def teardown
    # as we are re-initializing @post before every test
    # setting it to nil here is not essential but I hope
    # you understand how you can use the teardown method
  end

  # the users have names of music groups
  test "Friends receive the notification when a user starts reading abook that his friends have read" do
    book = Book.find_by_asin '8498382548' 
    scorpions = User.find_by_uid '100003593065982'
    acdc = User.find_by_uid scorpions.friends.first['id']
    # The acdc user doesn't have any notification yet
    keys = REDIS.lrange("user:#{acdc.id}:notifications", 0, 20)
    assert_equal keys, []
    count = REDIS.get "user:#{acdc.id}:noti_count"
    assert_nil count

    Experience.create do |experience|
        experience.book_id = book.id
        experience.user_id = acdc.id 
        experience.started_at = Time.now 
        experience.code = 0
    end
    # After creating an experience, acdc continues without having notification
    keys = REDIS.lrange("user:#{acdc.id}:notifications", 0, 20)
    assert_equal keys, []
    count = REDIS.get "user:#{acdc.id}:noti_count"
    assert_nil count

    experience = Experience.create do |experience|
        experience.book_id = book.id
        experience.user_id = scorpions.id
        experience.started_at = Time.now 
        experience.code = 0
    end

    # After creating an experience, acdc continues without having notification
    keys = REDIS.lrange("user:#{acdc.id}:notifications", 0, 20)
    assert_equal keys.first, "experience:#{experience.id}"
    assert_equal keys.size, 1
    count = REDIS.get "user:#{acdc.id}:noti_count"
    assert_equal count, '1'
     

  end

end
