require 'facebook_user_seed'

desc "This tasks shows test user"
task :load_facebook_users => :environment do
  User.all.each { |user| user.destroy}
  FacebookUserSeed.seed 

end
