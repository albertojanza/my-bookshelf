require 'test_helper'
require 'facebook_user_seed'
require 'facebook_api'


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




end
