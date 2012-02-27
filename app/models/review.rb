class Review < ActiveRecord::Base
  belongs_to :user
  belongs_to :book

  validates :user, :presence => true
  validates :book, :presence => true
  validates :content, :presence => true

  attr_accessible :book_id,:user_id,:content


end
