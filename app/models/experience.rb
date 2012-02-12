class Experience < ActiveRecord::Base

  belongs_to :user
  #belongs_to :adventure
  belongs_to :book
  has_many :comments
  #belongs_to :resource, :polymorphic => true, :dependent => :destroy
  belongs_to :recommender, :class_name => 'User',:foreign_key  => 'recommender_id'


  attr_accessible :text


end
