require 'test_helper'
require 'facebook_user_seed'
require 'facebook_api'


class ExperiencesBusinessTest < ActiveSupport::TestCase

######################################
## THis task loads the Facebook users. It is cool to run it before passing the test to avoid to ask for the users before every test
## rake load_facebook_users RAILS_ENV=test --trace
## ruby -Itest test/unit/interactions_dao_test.rb -n test_Notifications_in_a_book_recommendation. 
############################################3

  def setup
    #if User.count.eql? 0
    #  FacebookUserSeed.seed
    #else 
    #  user = User.last
    #  begin 
    #    user.friends
    #  rescue User::TokenExpiration
    #    User.all.each {|user| user.destroy}
    #    FacebookUserSeed.seed
    #  end
    #end
   Rails.cache.clear
   REDIS.flushdb
  end
 
  def teardown
    # as we are re-initializing @post before every test
    # setting it to nil here is not essential but I hope
    # you understand how you can use the teardown method
  end


  # Checking out the updates in a experience recommendations. When a user accepts the recommendation and moves it to a bookshelf
  #Scenario: Scorpions and Bunbury read the same two books, Scorpions recommends those books to aerosmith and aerosmith discards one and reads the other one.
  test 'Facebook app-generated request.' do
    book1 = Book.find_by_asin '8498382548' 
    book2 = Book.find_by_asin '0425243273'

    # These three guys are friends
    scorpions = User.find_by_uid '100003593065982'
    bunbury = User.find_by_uid '100003529976191'
    aerosmith = User.find_by_uid '100003533216061'
    FacebookApi.delete_all_request(scorpions.uid,scorpions.token)
    FacebookApi.delete_all_request(bunbury.uid,bunbury.token)
    FacebookApi.delete_all_request(aerosmith.uid,aerosmith.token)

    
    # Scorpions marks the first book as read
    experience1 = Experience.create do |experience|
        experience.book_id = book1.id
        experience.user_id = scorpions.id
        experience.started_at = Time.now 
        experience.code = 0
    end
    ExperiencesBusiness.create_experience(experience1,'APP-GENERATED')

    # Scorpions marks the book as read
    experience2 = Experience.create do |experience|
        experience.book_id = book2.id
        experience.user_id = scorpions.id
        experience.started_at = Time.now 
        experience.code = 0
    end
    ExperiencesBusiness.create_experience(experience2,'APP-GENERATED')

    # Bunbury marks the first book as read
    experience3 = Experience.create do |experience|
        experience.book_id = book1.id
        experience.user_id = bunbury.id
        experience.started_at = Time.now 
        experience.code = 0
    end
    ExperiencesBusiness.create_experience(experience3,'APP-GENERATED')

    # Bunbury marks the book as read
    experience4 = Experience.create do |experience|
        experience.book_id = book2.id
        experience.user_id = bunbury.id
        experience.started_at = Time.now 
        experience.code = 0
    end
    ExperiencesBusiness.create_experience(experience4,'APP-GENERATED')

    notifications = NotificationsBusiness.get_news_notifications(scorpions.id)
    assert_equal notifications[0]['id'], experience4.id.to_s
    assert_equal notifications[1]['id'], experience3.id.to_s
    assert_equal '2', NotificationsBusiness.news_notifications_count(scorpions.id)

    assert_equal [], NotificationsBusiness.get_news_notifications(bunbury.id)
    assert_nil  NotificationsBusiness.news_notifications_count(bunbury.id)

    # Scorpions sends a recommendation to aerosmtih
    experience5 = Experience.create do |experience|
        experience.book_id = book1.id
        experience.user_id = aerosmith.id
        experience.recommender_id = scorpions.id
        experience.started_at = Time.now 
        experience.code = 3
    end
    ExperiencesBusiness.create_experience(experience5,'APP-GENERATED')

    # Scorpions sends a recommendation to
    experience6 = Experience.create do |experience|
        experience.book_id = book2.id
        experience.user_id = aerosmith.id
        experience.recommender_id = scorpions.id
        experience.started_at = Time.now 
        experience.code = 3
    end
    ExperiencesBusiness.create_experience(experience6,'APP-GENERATED')

    # Scorpions hasn't received any new notification
    notifications = NotificationsBusiness.get_news_notifications(scorpions.id)
    assert_equal notifications[0]['id'], experience4.id.to_s
    assert_equal notifications[1]['id'], experience3.id.to_s
    assert_equal '2', NotificationsBusiness.news_notifications_count(scorpions.id)

    # Bunbury hasn't received any notification at all
    assert_equal [], NotificationsBusiness.get_news_notifications(bunbury.id)
    assert_nil  NotificationsBusiness.news_notifications_count(bunbury.id)


    # Aerosmith moves the first recommendation to the next read shelf
      experience5.code = 2 
      experience5.save
    
    #Scorpions doesn't receive a new notification
    notifications = NotificationsBusiness.get_news_notifications(scorpions.id)
    assert_equal notifications[0]['id'], experience4.id.to_s
    assert_equal notifications[1]['id'], experience3.id.to_s
    assert_equal '2', NotificationsBusiness.news_notifications_count(scorpions.id)
    
    #Scorpions receive a notification on his recommendations

    # Bunbury receives a notification
    notifications = NotificationsBusiness.get_news_notifications(scorpions.id)
    assert_equal notifications[0]['id'], experience5.id.to_s
    assert_equal notifications[0]['code'], '2'
    assert_equal '1',  NotificationsBusiness.news_notifications_count(bunbury.id)


  end

end
