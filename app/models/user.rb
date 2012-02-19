class User < ActiveRecord::Base

  #has_many :authentications
  has_many :experiences 
  #has_many :adventures, :through => :experiences
  has_many :books, :through => :experiences
  has_many :recommendations,  :class_name => 'Experience',:foreign_key  => 'recommender_id'

  validates :uid, :uniqueness => true

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

  def remove_experiences_and_books_cache
      Rails.cache.write "user_book_list_#{self.id}", nil
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
      Rails.cache.write "friend_#{self.id}", friends_data['data'] #(friends_data['data'].map! {|value| value['id']})
      friends_data['data']
    else
      friends
    end
  end

  def friends_reading


#    auths = Authentication.includes(:users).find(:all, self.friends)
  resul = []  

  my_friends = self.friends
  unless  my_friends.empty?
    select = '('
    if  my_friends.size > 1
      my_friends[0..(my_friends.size - 2)].each do |friend|
        select << "uid = '#{friend['id']}' OR "
      end
      select << "' uid = #{my_friends[my_friends.size - 1]['id']}')"
    else
      " uid = '#{my_friend[my_friends.size - 1]['id']}')" 
    end
    select << ' AND code = 1 '

    Experience.joins(:user).where(select).order('experiences.updated_at DESC').limit(100).includes(:book).includes(:user)

  end

  end

  # from an uid list this method returns those friends with that uid
  def friends? uid_list
    #my_friends = self.friends.map {|friend| friend['id']}
    #uid_list.all? {|friend_uid| my_friends.include? friend_uid }
    self.friends.select{ |friend| uid_list.include? friend['id'] }
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
