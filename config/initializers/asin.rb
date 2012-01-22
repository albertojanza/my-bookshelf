ASIN::Configuration.configure do |config|
  config.key          = ENV['AWS_KEY']
  config.secret       = ENV['AWS_SECRET']
  config.associate_tag =ENV['AWS_ASSOCIATE_TAG']


end
