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
