class Authentication < ActiveRecord::Base
  belongs_to :user
  serialize :info

end
