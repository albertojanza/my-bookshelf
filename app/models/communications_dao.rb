class CommunicationsDao


    def self.user_notifications_old(user_id)
      dynamo = AWS::DynamoDB.new
      table = dynamo.tables['notifications']
      table.load_schema
      table.items.query( hash_value: 23 , range_greater_than: 31.days.ago.to_i)
     # table.items.at user_id, 2.days.ago.to_i 
     # table.batch_get(:all, [[25,2.days.ago.to_i]])


    end

  def self.user_notifications(user_id)
    redis = Redis.new(:host => "localhost", :port => 6379)
    redis.lrange "user:#{user_id}:notifications", 0, 20
    
  end

end 
