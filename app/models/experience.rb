class Experience < ActiveRecord::Base

  belongs_to :user
  belongs_to :adventure
  has_many :comments
  belongs_to :resource, :polymorphic => true, :dependent => :destroy

  attr_accessible :text


end
