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


  # Scenario: Three friends: Scorpions, Aeromisth and Bubury. 
  # Two of them mark a book as a read and then of them sends a recommendation of this book to the third one.
  test 'Notifications in a book recommendation.' do
    book = Book.find_by_asin '8498382548' 
    # These three guys are friends
    scorpions = User.find_by_uid '100003593065982'
    bunbury = User.find_by_uid '100003529976191'
    aerosmith = User.find_by_uid '100003533216061'

    # We check out that they don't have any notifications
    assert_nil NotificationsBusiness.news_notifications_count(scorpions.id)
    assert_equal NotificationsBusiness.get_news_notifications(scorpions.id), []
    assert_nil NotificationsBusiness.news_notifications_count(aerosmith.id)
    assert_equal NotificationsBusiness.get_news_notifications(aerosmith.id), []
    assert_nil NotificationsBusiness.news_notifications_count(bunbury.id)
    assert_equal NotificationsBusiness.get_news_notifications(bunbury.id), []

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
    # We check out that scorpions receives a notification 
    assert_equal NotificationsBusiness.news_notifications_count(scorpions.id), '1'
    assert_equal NotificationsBusiness.get_news_notifications(scorpions.id).first['id'], experience2.id.to_s
    assert_nil NotificationsBusiness.news_notifications_count(aerosmith.id)
    assert_equal NotificationsBusiness.get_news_notifications(aerosmith.id), []
    assert_nil NotificationsBusiness.news_notifications_count(bunbury.id)
    assert_equal NotificationsBusiness.get_news_notifications(bunbury.id), []

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
    assert_equal NotificationsBusiness.news_notifications_count(scorpions.id), '1'
    assert_equal NotificationsBusiness.get_news_notifications(scorpions.id).first['id'], experience2.id.to_s
    assert_nil NotificationsBusiness.news_notifications_count(aerosmith.id)
    assert_equal NotificationsBusiness.get_news_notifications(aerosmith.id), []
    # We check out that aerosmith has this recommendation on it recommendation inbox.
    assert_equal NotificationsBusiness.news_notifications_count(bunbury.id), '1'
    assert_equal NotificationsBusiness.get_news_notifications(bunbury.id).first['id'], experience3.id.to_s


    # We check out that bunbury has this recommendation on its recommendation list.
    assert_equal ExperiencesBusiness.get_recommendation_list(bunbury.id).first['id'], experience3.id.to_s


  end

end
