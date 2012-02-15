class User < ActiveRecord::Base

  #has_many :authentications
  has_many :experiences 
  #has_many :adventures, :through => :experiences
  has_many :books, :through => :experiences
  has_many :recommendations,  :class_name => 'Experience',:foreign_key  => 'recommender_id'

  def experiences_and_books_cache
    books = Rails.cache.fetch "user_book_list_#{self.id}"
    unless books
      experiences = self.experiences.includes(:book)
      books = {}
      experiences.each { |experience| books[experience.book.asin] = [experience.id,experience.code]}
      Rails.cache.write "user_book_list_#{self.id}", books
    end
    books
  end


  def friends
    friends = Rails.cache.fetch "friend_#{self.id}"
    unless friends
      http = Net::HTTP.new "graph.facebook.com", 443
      request = Net::HTTP::Get.new "/me/friends?access_token=#{self.token}"
      http.use_ssl = true
      response = http.request request
      friends_data = MultiJson.decode(response.body)
      raise(User::TokenExpiration.new(self,friends_data['error']['message'])) if friends_data['error'] && friends_data['error']['type'].eql?('OAuthException')
      Rails.cache.write "friend_#{self.id}", (friends_data['data'].map! {|value| value['id']})
      friends_data['data']
    else
      friends
    end
  end

  def friends_reading


#    auths = Authentication.includes(:users).find(:all, self.friends)
  resul = []  
  unless  self.friends.empty?
    select = ''
    if self.friends.size > 1
      self.friends[0..(self.friends.size - 2)].each do |uid|
        select << "uid = '#{uid}' OR "
      end
      select << friends[self.friends.size - 1]
    else
      " uid = '#{uid}'" 
    end
    select << ' AND code = 1 '

    Experience.joins(:user).where(select).order('experiences.updated_at DESC').limit(100).includes(:book).includes(:user)

  end


  end

class TokenExpiration < Exception
  attr :user
  attr :message
  def initialize(user,message)
    @user = user
    @message = message
  end
end
end
