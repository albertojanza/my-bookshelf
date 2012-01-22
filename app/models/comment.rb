class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :experience

  attr_accessible :text
  validates_presence_of :text, :allow_blank => false


end
