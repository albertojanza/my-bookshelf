class InteractionsDao

  ###########################
  # Cassandra: Facebook requests. x
  # Redis: Set. We track every facebook request 
  # fb_requests:1232343453
  # It is a hash. When the user attends the request, we remove the request from its user set, and we update this hash to track if the request was attend by:
  # - "source"=>"fb_request"
  # - "source" => "web-news"
  # Hash structure 
  #   - mandatory fields : user_id', 'user_uid', type
  #   - optional fields experience_id
  # type values: 
  #   - app_generated_notification # notification that a friend is reading the same book that you have read
  #   - app_generated_recommendation # recommendation to a book
  #   - user_generated_invitation # invitation to use the app 
  #   - user_generated_recommendation # invitation to use the app 
  ########################

  ###########################
  # Cassandra: User facebook request. Inverted index
  # Redis: Set. We track every facebook request that has been sent to an user
  # user:12:fb_requests
  # It is a set.
  ########################

  ###########################
  # Cassandra: User Notifications. Inverted index
  # Redis: Every user has a list of notifications
  # user:12:notifications
  # It is an inverted index that point to the objets that have generated the notifications. For example an experience
  ########################

  ###########################
  # Cassandra: User Recommendations. Inverted index
  # Redis: Every user has a list of recommendations that he has sent
  # user:12:recommendations
  # It is an inverted index that point to the objets that have generated the recommendations. For example an experience
  ########################

  ####################################
  # Cassandra: Experiences.
  # Redis: experience is a object which we store in a hash structure
  # experience:id
  ########################

  ####################################
  # Cassandra: Experience notifications. Inverted Index
  # Redis: We need to keep track which users have been notified. To be able to remove the notifications. 
  # experience:id:notifications
  ########################

  #####################################
  ## COUNTERs
  ## Notification counter per user
  ## user:12:noti_count
  ## user:12:reco_count
  ## user:12:fb_requests_count
  #######################################
  
  def self.notifications_count(user_id)
    REDIS.get "user:#{user_id}:noti_count"
  end

  def self.get_notifications(user_id)
    keys = REDIS.lrange("user:#{user_id}:notifications", 0, 20)
    items = []
    #redis.pipelined do
      keys.each { |key| items << REDIS.hgetall(key) }
      
    #end
    items
  end

  def self.set_notifications(experience)
    friend_uids = experience.user.friends.map {|friend|  friend['id']}
    readers = experience.book.cache_people_are_reading + experience.book.cache_people_have_read +  experience.book.cache_people_will_read + experience.book.cache_people_with_recommendations
    friends_have_read_it = readers.select{ |user| friend_uids.include?(user[:uid])  }
    REDIS.hmset "experience:#{experience.id}", 'user_id', experience.user.id, 'user_name', experience.user.name, 'user_uid', experience.user.uid, 'code', experience.code, 'title', experience.book.title, 'image', experience.book.tiny_image, 'author', (experience.book.author.class.eql?(Array) ? experience.book.author.to_json : [experience.book.author].to_json), 'book_id',  experience.book.permalink
    REDIS.hmset "experience:#{experience.id}", 'recommender_id', experience.recommender.id, 'recommender_name', experience.recommender.name, 'recommender_uid', experience.recommender.uid if experience.recommender
    # Be careful, we dont send app-generated notifications to facebook when the experience is a recommendation. 
    # Because we have to differenciate between app-generated and user-generated recommendations
    unless experience.code.eql? 3
      friends_have_read_it.each do |user| 
        unless user.eql? experience.recommender
          REDIS.lpush "user:#{user[:id]}:notifications", "experience:#{experience.id}"
          REDIS.incr "user:#{user[:id]}:noti_count"

            # Facebook app-generated requests
            data = FacebookApi.send_request(user[:uid],self.facebook_request_message(experience.code, user[:name]), experience.id)
            REDIS.hmset "fb_requests:#{data['request']}", 'user_id', experience.user.id, 'user_uid', experience.user.uid, 'experience_id', "experience:#{experience.id}", 'type', 'app_generated_notification'
            REDIS.sadd "user:#{user[:id]}:fb_requests", "#{data['request']}"
            REDIS.incr "user:#{user[:id]}:fb_requests_count"
        
        end
      end
    end

    friends_have_read_it.each do |user| 
      REDIS.lpush "experience:#{experience.id}:notifications", "user:#{user[:id]}" unless user.eql? experience.recommender
    end
    if experience.recommender
        REDIS.lpush "user:#{experience.recommender.id}:recommendations", "experience:#{experience.id}"
        REDIS.incr "user:#{experience.recommender.id}:reco_count"
    end

  end

  def self.track_fb_invitation_request(request,to)
    user = User.find_by_uid(to.first)
    user = User.create(:uid => to.first) unless user
    REDIS.hmset "fb_requests:#{request}", 'user_id', user.id, 'user_uid', user.uid, 'type', 'user_generated_invitation'
    REDIS.sadd "user:#{user[:id]}:fb_requests", request
    REDIS.incr "user:#{user[:id]}:fb_requests_count"
    #REDIS.smembers 'user:24:fb_requests'
  end

  def self.app_generated_fb_recommendation_request(experience)
        # Facebook app-generated requests
        data = FacebookApi.send_request(user[:uid],self.facebook_request_message(experience.code, user[:name]), experience.id)
        REDIS.hmset "fb_requests:#{data['request']}", 'user_id', experience.user.id, 'user_uid', experience.user.uid, 'experience_id', "experience:#{experience.id}", 'type', 'app_generated_recommendation'
        REDIS.sadd "user:#{user[:id]}:fb_requests", "#{data['request']}"
        REDIS.incr "user:#{user[:id]}:fb_requests_count"

  end

  def self.user_generated_fb_recommendation_request(request,to)

    request_info = FacebookApi.get_request request
    recommender = User.find_by_uid request_info['from']['id']
    to.each do |uid|
      user = User.find_by_uid(uid)
      user = User.create(:uid => to.first) unless user
      experience = Experience.create do |experience|
        experience.book_id requ request_info['data']
        experience.user_id = user.id
        experience.recommender_id = recommender.id
        experience.started_at = Time.now 
        experience.code = 3
      end

      REDIS.hmset "fb_requests:#{request}", 'user_id', user.id, 'user_uid', user.uid, 'experience_id', experience.id, 'type', 'user_generated_recommendation'
      REDIS.sadd "user:#{user[:id]}:fb_requests", request
      REDIS.incr "user:#{user[:id]}:fb_requests_count"
      #REDIS.smembers 'user:24:fb_requests'
    end
  end


private

  def self.facebook_request_message code, name
    case code
      when 0
        I18n.t 'fb_request_read_book', :name => name
      when 1
        I18n.t 'fb_request_reading_book', :name => name
      when 2
        I18n.t 'fb_request_next_book', :name => name
      when 3
        I18n.t 'fb_request_recommendation_book', :name => name
    end
  end

end
