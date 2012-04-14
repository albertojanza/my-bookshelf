if Rails.env.eql?('development')
  REDIS    = Redis.new(:host => 'localhost', :port => 6379, :db => 0)
elsif Rails.env.eql?('production')
  REDIS    = Redis.new(:host => 'localhost', :port => 6379, :db => 3)
else
  REDIS    = Redis.new(:host => 'localhost', :port => 6379, :db => 1)
end

