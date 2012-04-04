require 'test_helper'
require 'facebook_user_seed'


class InteractionsDaoTest < ActiveSupport::TestCase

  # called before every single test
  def setup
    if User.count.eql? 0
      FacebookUserSeed.seed
    end
    redis = Redis.new(:host => 'localhost', :port => 6379, :db => 1)
    #redis.select 1
    redis.flushdb
  end
 
  # called after every single test
  def teardown
    # as we are re-initializing @post before every test
    # setting it to nil here is not essential but I hope
    # you understand how you can use the teardown method
  end

   test "the truth" do
     assert true
   end

end
