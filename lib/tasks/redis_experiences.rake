require 'facebook_user_seed'

desc "Duplicating the experiences information for the Redis system"
task :redis_experiences => :environment do
  Experience.all.each do |experience| 
    # Creating the experience hash in REdis
    REDIS.hmset "experience:#{experience.id}", 'user_id', experience.user.id, 'user_name', experience.user.name, 'user_uid', experience.user.uid, 'code', experience.code, 'title', experience.book.title, 'image', experience.book.tiny_image, 'author', (experience.book.author.class.eql?(Array) ? experience.book.author.to_json : [experience.book.author].to_json), 'book_id',  experience.book.permalink, 'id', experience.id
    REDIS.hmset "experience:#{experience.id}", 'recommender_id', experience.recommender.id, 'recommender_name', experience.recommender.name, 'recommender_uid', experience.recommender.uid if experience.recommender

  end
end
