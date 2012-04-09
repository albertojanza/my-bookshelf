class FbRequestsBusiness
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

  #####################################
  ## COUNTERs
  ## user:12:fb_requests_count
  #######################################

  def self.get_facebook_requests(user_id)
    keys = REDIS.smembers("user:#{user_id}:fb_requests")
    items = []
    #redis.pipelined do
      keys.each { |key| items << REDIS.hgetall(key) }
    #end
    items
  end

  def self.fb_requests_count(user_id)
    news_count = REDIS.get "user:#{user_id}:fb_requests_count" 
  end

  def self.track_fb_invitation_request(request,to)
    to.each do |uid|
      user = User.find_by_uid(uid)
      user = User.create(:uid => to.first) unless user
      REDIS.hmset "fb_requests:#{request}", 'user_id', user.id, 'user_uid', user.uid, 'type', 'user_generated_invitation'
      REDIS.sadd "user:#{user[:id]}:fb_requests", request
      REDIS.incr "user:#{user[:id]}:fb_requests_count"
      #REDIS.smembers 'user:24:fb_requests'
    end
  end

  def self.app_generated_fb_recommendation_requests(experience)
        # Facebook app-generated requests
        data = FacebookApi.send_request(experience.user.uid,self.facebook_request_message(experience.code, experience.user.name), experience.id)
        REDIS.hmset "fb_requests:#{data['request']}", 'user_id', experience.user.id, 'user_uid', experience.user.uid, 'experience_id', "experience:#{experience.id}", 'type', 'app_generated_recommendation'
        REDIS.sadd "user:#{experience.user.id}:fb_requests", "#{data['request']}"
        REDIS.incr "user:#{experience.user.id}:fb_requests_count"

  end


  def self.app_generated_fb_requests(experience)
    friend_uids = experience.user.friends.map {|friend|  friend['id']}
    readers = experience.book.cache_people_are_reading + experience.book.cache_people_have_read +  experience.book.cache_people_will_read + experience.book.cache_people_with_recommendations
    friends_have_read_it = readers.select{ |user| friend_uids.include?(user[:uid])  }
    friends_have_read_it.each do |user| 
        data = FacebookApi.send_request(user[:uid],self.facebook_request_message(experience.code, experience.user.name), experience.id)
        REDIS.sadd "user:#{user[:id]}:fb_requests", "#{data['request']}"
        REDIS.incr "user:#{user[:id]}:fb_requests_count"
    end
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

      ExperiencesBusiness.create_experience(@experience,'USER-GENERATED')

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
