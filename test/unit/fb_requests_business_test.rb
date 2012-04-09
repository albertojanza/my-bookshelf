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

    # We check out that scorpions doesn't receives a new notification and that bunbury has received a recomendation
    assert_equal FbRequestsBusiness.fb_requests_count(scorpions.id), '1'
    assert_equal FbRequestsBusiness.get_facebook_requests(scorpions.id).size, 1
    assert_nil FbRequestsBusiness.fb_requests_count(bunbury.id)
    assert_equal FbRequestsBusiness.get_facebook_requests(bunbury.id), []
    assert_equal FbRequestsBusiness.fb_requests_count(aerosmith.id), '1'
    assert_equal FbRequestsBusiness.get_facebook_requests(aerosmith.id).size, 1 

  end



end
