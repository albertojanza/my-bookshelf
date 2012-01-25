class Adventure < ActiveRecord::Base
  belongs_to :resource, :polymorphic => true, :dependent => :destroy
  has_many :experiences

end
