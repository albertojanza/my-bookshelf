class NotificationsBusiness

  ###########################
  # Cassandra: User News_Notifications. Inverted index
  # Redis: Every user has a list of notifications
  # user:12:news_notifications
  # It is an inverted index that point to the objets that have generated the notifications. For example an experience
  ########################

  ###########################
  # Cassandra: User Recommendation_Notifications. Inverted index
  # Redis: Every user has a list of recommendations that he has sent
  # user:12:reco_notifications
  # It is an inverted index that point to the objets that have generated the recommendations. For example an experience
  ########################

  #####################################
  ## COUNTERs
  ## Notification counter per user
  ## user:12:news_count
  ## user:12:reco_count
  #######################################
  

  def self.reset_reco_notifications_count(user_id)
    news_count = REDIS.set "user:#{user_id}:reco_count", '0'
  end

  def self.reset_news_notifications_count(user_id)
    news_count = REDIS.set "user:#{user_id}:news_count", '0'
  end

  def self.reco_notifications_count(user_id)
    news_count = REDIS.get "user:#{user_id}:reco_count" 
  end

  def self.news_notifications_count(user_id)
    news_count = REDIS.get "user:#{user_id}:news_count" 
  end

  def self.notifications_count(user_id)
    news_count = REDIS.get "user:#{user_id}:news_count" 
    reco_count = REDIS.get "user:#{user_id}:reco_count"
    if news_count.nil? && reco_count.nil?
      nil
    else
      ((news_count.nil? ? 0 : news_count.to_i) + (reco_count.nil? ? 0 : reco_count.to_i)).to_s
    end
  end

  def self.get_news_notifications(user_id)
    keys = REDIS.lrange("user:#{user_id}:news_notifications", 0, 20)
    items = []
    #redis.pipelined do
      keys.each { |key| items << REDIS.hgetall(key) }
      
    #end
    items
  end

  def self.get_reco_notifications(user_id)
    keys = REDIS.lrange("user:#{user_id}:reco_notifications", 0, 20)
    items = []
    #redis.pipelined do
      keys.each { |key| items << REDIS.hgetall(key) }
      
    #end
    items
  end

  # Generate echo-notification in the news on Libroshelf for every friend that has read or is reading the book
  def self.set_news_notifications(experience)
    friend_uids = experience.user.friends.map {|friend|  friend['id']}
    readers = experience.book.cache_people_are_reading + experience.book.cache_people_have_read +  experience.book.cache_people_will_read + experience.book.cache_people_with_recommendations
    friends_have_read_it = readers.select{ |user| friend_uids.include?(user[:uid])  }
    friends_have_read_it.each do |user| 
      # echo in the newsfeed on Libroshelf
      REDIS.lpush "user:#{user[:id]}:news_notifications", "experience:#{experience.id}"
      REDIS.incr "user:#{user[:id]}:news_count"
    end
    friends_have_read_it.each do |user| 
      REDIS.sadd "experience:#{experience.id}:news_notifications", "user:#{user[:id]}" 
    end
  end

  # Generate echo-notification in the news on Libroshelf for every friend that has read or is reading the book
  def self.update_news_notifications(experience)
    users =  REDIS.smembers "experience:#{experience.id}:news_notifications"
    users.each do |user|  
      REDIS.lrem "#{user}:news_notifications", 0, "experience:#{experience.id}"
      REDIS.lpush "#{user}:news_notifications", "experience:#{experience.id}"
      REDIS.incr "#{user}:news_count"
    end
  end

  def self.delete_news_notifications(experience)
      users = REDIS.smembers "experience:#{experience.id}:news_notifications"
      users.each do |user|  
        REDIS.lrem "#{user}:news_notifications", 0, "experience:#{experience.id}"
      end
      notifications = REDIS.del "experience:#{experience.id}:news_notifications"
  end

  def self.delete_reco_notifications(experience)
      REDIS.lrem "user:#{experience.user.id}:reco_notifications", 0, "experience:#{experience.id}"
  end


  # Generate echo-notification in the news on Libroshelf for every friend that has read or is reading the book
  def self.set_recommendation_notifications(experience)

    REDIS.lpush "user:#{experience.user.id}:reco_notifications", "experience:#{experience.id}"
    REDIS.incr "user:#{experience.user.id}:reco_count"

  end


end
