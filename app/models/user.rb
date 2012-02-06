class User < ActiveRecord::Base

  has_many :authentications
  has_many :experiences 
  has_many :adventures, :through => :experiences


  def friends
    friends = Rails.cache.fetch "friend_#{self.id}"
    unless friends
      puts "sfasf"
      facebook_auth = (self.authentications.find {|auth| auth if auth.provider.eql?('facebook') }) 
      http = Net::HTTP.new "graph.facebook.com", 443
      request = Net::HTTP::Get.new "/me/friends?access_token=#{facebook_auth.token}"
      http.use_ssl = true
      response = http.request request
      friends_data = MultiJson.decode(response.body)
      raise(Authentication::TokenExpiration.new(facebook_auth,friends_data['error']['message'])) if friends_data['error'] && friends_data['error']['type'].eql?('OAuthException')
      Rails.cache.write "friend_#{self.id}", friends_data['data']
    end
    friends || Rails.cache.fetch("friend_#{self.id}")
  end
end
