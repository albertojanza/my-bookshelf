require 'facebook_user_seed'

desc "This tasks shows test user"
task :create_notifications => :environment do
  Experience.all.each do |experience|
    ExperiencesBusiness.create_experience(experience,'APP-GENERATED')
  end

end
