class InteractionsDao

  ###########################
  # Cassandra: User Notifications. Inverted index
  # Redis: Every user has a list of notifications
  # user:12:notifications
  # It is an inverted index that point to the objets that have generated the notifications. For example an experience
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
  ## Notification counter per user
  ## user:12:noti_count
  #######################################
  
  def self.notifications_count(user_id)
    redis = Redis.new(:host => 'localhost', :port => 6379)
    redis.get "user:#{user_id}:noti_count"
  end

  def self.get_notifications(user_id)
    redis = Redis.new(:host => 'localhost', :port => 6379)
    keys = redis.lrange("user:#{user_id}:notifications", 0, 20)
    items = []
    #redis.pipelined do
      keys.each { |key| items << redis.hgetall(key) }
      
    #end
    items
  end

  def self.set_notifications(experience)
    redis = Redis.new(:host => 'localhost', :port => 6379)
    friend_uids = experience.user.friends.map {|friend|  friend['id']}
    readers = experience.book.cache_people_are_reading + experience.book.cache_people_have_read +  experience.book.cache_people_will_read + experience.book.cache_people_with_recommendations
    friends_have_read_it = readers.select{ |user| friend_uids.include?(user[:uid])  }
    redis.hmset "experience:#{experience.id}", 'user_id', experience.user.id, 'user_name', experience.user.name, 'user_uid', experience.user.uid, 'code', experience.code, 'title', experience.book.title, 'image', experience.book.tiny_image, 'author', experience.book.author.to_json, 'book_id',  experience.book.id
    redis.hmset "experience:#{experience.id}", 'recommender_id', experience.user.id, 'recommender_name', experience.user.name, 'recommender_uid', experience.user.uid if experience.recommender
    friends_have_read_it.each do |user| 
      unless user.eql? experience.recommender
        redis.lpush "user:#{user[:id]}:notifications", "experience:#{experience.id}"
        redis.incr "user:#{user[:id]}:noti_count"
      end
    end
    friends_have_read_it.each do |user| 
      redis.lpush "experience:#{experience.id}:notifications", "user:#{user[:id]}" unless user.eql? experience.recommender
    end
  end

end
