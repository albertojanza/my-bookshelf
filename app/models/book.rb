class Book < ActiveRecord::Base
  has_one :adventure, :as => :resource

end
