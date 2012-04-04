class Experience < ActiveRecord::Base

  belongs_to :user
  #belongs_to :adventure
  belongs_to :book
  #belongs_to :resource, :polymorphic => true, :dependent => :destroy
  belongs_to :recommender, :class_name => 'User',:foreign_key  => 'recommender_id'
  belongs_to :evangelist, :class_name => 'User',:foreign_key  => 'evangelist_id'
  belongs_to :influencer, :class_name => 'User',:foreign_key  => 'influencer_id'

  attr_accessible :code

  validates :code, :inclusion => { :in => [0,1, 2, 3] , :message => "%{value} is not a valid size" }
  validate :duplicated_experiences, :on => :create
  validates :user, :presence => true
  validates :book, :presence => true
  before_save :recommender_to_influencer
  after_update :count_influences
  after_save :remove_book_cache
  after_save :remove_experiences_and_books_cache
  after_save :count_experiences
  before_save :facebook_action
  after_create :set_notifications

  def set_notifications
    InteractionsDao.set_notifications(self)
  end


  def facebook_action
  unless (Rails.env.eql?('development') || Rails.env.eql?('test'))
   if code.eql?(0)
    http = Net::HTTP.new "graph.facebook.com", 443
    http.use_ssl = true
    if   Rails.env.eql?('development')
      post =  "/me/teachingandsurfing:reading?" if code.eql?(1)
      post = "/me/teachingandsurfing:read?" if code.eql?(0)
    else
      post =  "/me/libroshelf:reading?" if code.eql?(1)
      post = "/me/libroshelf:read?" if code.eql?(0)
    end

    request = Net::HTTP::Post.new post
    request.set_form_data({ 'book' => Rails.application.routes.url_helpers.book_url(self.book,:host => (Rails.env.eql?('development') ? 'localhost' : 'libroshelf.com')),'access_token' => self.user.token})
    response = http.request request
    data = MultiJson.decode(response.body)
    raise(User::TokenExpiration.new(self,data['error']['message'])) if data['error'] && data['error']['type'].eql?('OAuthException') && data['error']['code'].eql?(190)
    i=0
    while (data['error'] && (i < 10)) do
      i = i + 1
      response = http.request request 
      data = MultiJson.decode(response.body)
    end
    if data['error']
      self.facebook_action_id = data['error']['message']
    else
      self.facebook_action_id = data['id']
    end
  end
  end
  end



  def remove_book_cache
    self.book.remove_cache_users_with_this_experience(self.code_was)
    self.book.remove_cache_users_with_this_experience(self.code)
  end

  def remove_experiences_and_books_cache
    self.user.remove_experiences_and_books_cache
  end


  def duplicated_experiences
    raise DuplicatedExperience.new(self,"Duplicated experience") if Experience.find_by_user_id_and_book_id(self.user_id,self.book_id)
  end

  def recommender_to_influencer
    self.influencer_id = self.recommender_id if self.recommender_id
  end

  def count_experiences
    if self.new_record?
      self.user.reading_count = self.user.reading_count + 1 if self.code.eql?(1)
      self.user.read_count = self.user.read_count + 1 if self.code.eql?(0)
    else
      self.user.reading_count = self.user.reading_count - 1 if self.code_was.eql?(1)
      self.user.reading_count = self.user.reading_count + 1 if self.code.eql?(1)
      self.user.read_count = self.user.read_count + 1 if self.code.eql?(0)
    end
    self.user.save

  end


  def count_influences
    if self.influencer_id
      if  self.influencer_id.eql?(self.recommender_id)
        case self.code
          when 0
            self.influencer.update_attribute(:influence_rate, self.influencer.influence_rate + 3)
          when 1
            self.influencer.update_attribute(:influence_rate, self.influencer.influence_rate + 2)
          when 2
            self.influencer.update_attribute(:influence_rate, self.influencer.influence_rate + 1)
          end
      else 
        self.influencer.influence_rate = self.influencer.influence_rate + 1
      end
    end

  end

  def notifications_dynamo
    dynamo = AWS::DynamoDB.new
    table = dynamo.tables['notifications']
    table.load_schema
    friend_ids = self.user.friends.map {|friend|  friend['id']}
    self.book.cache_people_have_read.select{ |user| friend_ids.include?(user[:uid])  }.each do |user| 
      table.items.put(:id => user[:id], :time => Time.now.to_i, :uid => user[:uid], :name => user[:name], :book_id => self.book.id, :title => self.book.title, :author => self.book.author, :ex_code => 0, :reader_id => self.user.id,:reader_uid => self.user.uid,:reader_name => self.user.name, :reader_ex_code => self.code) 
    end
  end

  def notifications
    redis = Redis.new(:host => "localhost", :port => 6379)
    friend_ids = self.user.friends.map {|friend|  friend['id']}
    self.book.cache_people_have_read.select{ |user| friend_ids.include?(user[:uid])  }.each do |user| 
      redis.rpush "user:#{user[:id]}:notifications", {:book_id => self.book.id, :title => self.book.title, :author => self.book.author, :ex_code => 0, :reader_id => self.user.id,:reader_uid => self.user.uid,:reader_name => self.user.name, :reader_ex_code => self.code}.to_json
    end
  end

class DuplicatedExperience < Exception
  @experience
  @message

  def initialize(experience, message)
    @experience = experience
    @message = message
  end

end

end
