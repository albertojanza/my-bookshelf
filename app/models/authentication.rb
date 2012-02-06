class Authentication < ActiveRecord::Base
  belongs_to :user
  serialize :info


#class TokenExpiration < RuntimeError
#class TokenExpiration < ActiveRecord::Error
class TokenExpiration < Exception
  attr :authentication
  attr :message
  def initialize(authentication,message)
    @authentication = authentication
    @message = message
  end
end

end
