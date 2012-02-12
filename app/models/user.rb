class User < ActiveRecord::Base

  #has_many :authentications
  has_many :experiences 
  #has_many :adventures, :through => :experiences
  has_many :books, :through => :experiences
  has_many :recommendations,  :class_name => 'Experience',:foreign_key  => 'recommender_id'


  def friends
    friends = Rails.cache.fetch "friend_#{self.id}"
    unless friends
      facebook_auth = (self.authentications.find {|auth| auth if auth.provider.eql?('facebook') }) 
      http = Net::HTTP.new "graph.facebook.com", 443
      request = Net::HTTP::Get.new "/me/friends?access_token=#{facebook_auth.token}"
      http.use_ssl = true
      response = http.request request
      friends_data = MultiJson.decode(response.body)
      raise(User::TokenExpiration.new(facebook_auth,friends_data['error']['message'])) if friends_data['error'] && friends_data['error']['type'].eql?('OAuthException')
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

    Book.joins(:experiences => :user).where(select).order(:updated_at).limit(100)

  end


  end

class TokenExpiration < Exception
  attr :authentication
  attr :message
  def initialize(authentication,message)
    @authentication = authentication
    @message = message
  end
end
end
