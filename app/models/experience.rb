class Experience < ActiveRecord::Base

  belongs_to :user
  #belongs_to :adventure
  belongs_to :book
  has_many :comments
  #belongs_to :resource, :polymorphic => true, :dependent => :destroy
  belongs_to :recommender, :class_name => 'User',:foreign_key  => 'recommender_id'

  attr_accessible :code

  validates :code, :inclusion => { :in => [0,1, 2, 3] , :message => "%{value} is not a valid size" }
  validate :duplicated_experiences, :on => :create
  validates :user, :presence => true
  validates :book, :presence => true


  def duplicated_experiences
    raise DuplictedExperience(self,"Duplicated experience") if Experience.find_by_user_id_and_book_id(self.user_id,self.book_id)
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
