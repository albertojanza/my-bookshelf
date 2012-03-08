class Experience < ActiveRecord::Base

  belongs_to :user
  #belongs_to :adventure
  belongs_to :book
  has_many :comments
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

  def facebook_action
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
      puts "party"
    while (data['error'] && (i < 10)) do
      puts "party"
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


class DuplicatedExperience < Exception
  @experience
  @message

  def initialize(experience, message)
    @experience = experience
    @message = message
  end

end

end
