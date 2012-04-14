class ExperiencesBusiness

  ####################################
  # Cassandra: Experiences.
  # Redis: experience is a object which we store in a hash structure
  # experience:id
  ########################

  ####################################
  # Cassandra: Experience notifications. Inverted Index
  # Redis: We need to keep track which users have been notified. To be able to remove the notifications. 
  # experience:id:news_notifications
  ########################

  ####################################
  # Cassandra: Experience recommendations. Inverted Index
  # Redis:  We keep an index with every recomendation that an user has sent
  # user:id:recommendations
  ########################

  # A experience creation can trigger different notifications and request on Facebook depending on the type of experience.
  # Code: 0, 1 and 2
  #     - Notifications that inform to friends that have read the same book. For every friend the system will generate:
  #         - An echo-notification in the News on libroshelf. 
  #         - An app-generated request on Facebook.
  # Code: 3 -> Recommendation, 
  #   - Notifications
  #       - App-generated or user-generated requests for the receiver. 
  #       - Echo in the Recommendation feed on Libroshelf for the recommender and the receiver. 
  # Parameters
  #   - experience object -> active record
  #   - origin -> to differenciate when the recommendation has been generated in the canvas (through the Facebook request dialog) or on the web
  def self.create_experience(experience,origin=nil) 
    # Creating the experience hash in REdis
    REDIS.hmset "experience:#{experience.id}", 'user_id', experience.user.id, 'user_name', experience.user.name, 'user_uid', experience.user.uid, 'code', experience.code, 'title', experience.book.title, 'image', experience.book.tiny_image, 'author', (experience.book.author.class.eql?(Array) ? experience.book.author.to_json : [experience.book.author].to_json), 'book_id',  experience.book.permalink, 'id', experience.id
    REDIS.hmset "experience:#{experience.id}", 'recommender_id', experience.recommender.id, 'recommender_name', experience.recommender.name, 'recommender_uid', experience.recommender.uid if experience.recommender
    if experience.code.eql?(3)
      REDIS.lpush "user:#{experience.recommender.id}:recommendations", "experience:#{experience.id}"
      NotificationsBusiness.set_recommendation_notifications(experience)
      unless origin.eql?('USER-GENERATED')
        FbRequestsBusiness.app_generated_fb_recommendation_requests(experience)
      end
    else
      NotificationsBusiness.set_news_notifications(experience)
      # Facebook app-generated requests
      FbRequestsBusiness.app_generated_fb_requests(experience)
    end

  end

  def self.update_experience(experience) 
    REDIS.hmset "experience:#{experience.id}", 'recommender_id', experience.recommender.id, 'recommender_name', experience.recommender.name, 'recommender_uid', experience.recommender.uid  if experience.recommender
    REDIS.hmset "experience:#{experience.id}", 'recommender_id', experience.evangelist.id, 'recommender_name', experience.evangelist.name, 'recommender_uid', experience.evangelist.uid  if experience.evangelist
    REDIS.hmset "experience:#{experience.id}", 'recommender_id', experience.influencer.id, 'recommender_name', experience.influencer.name, 'recommender_uid', experience.influencer.uid  if experience.influencer
    unless experience.code.eql? experience.code_was
      old_codes =   REDIS.hget "experience:#{experience.id}", 'old_codes'
      if old_codes
        old_codes = JSON.parse old_codes
        old_codes << experience.code_was
      else
        old_codes = [experience.code_was]
      end
      REDIS.hmset "experience:#{experience.id}", 'code', experience.code, 'old_codes', old_codes.to_json
      NotificationsBusiness.update_news_notifications(experience)
      FbRequestsBusiness.app_generated_fb_requests(experience)
    end

  end

  def self.get_recommendation_list(user_id)
    keys = REDIS.lrange("user:#{user_id}:recommendations", 0, 20)
    items = []
    #redis.pipelined do
      keys.each { |key| items << REDIS.hgetall(key) }
    #end
    items
  end

end
