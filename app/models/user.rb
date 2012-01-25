class User < ActiveRecord::Base

  has_many :authentications
  has_many :experiences 
  has_many :adventures, :through => :experiences

end
