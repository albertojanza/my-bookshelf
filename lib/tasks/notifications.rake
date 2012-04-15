require 'facebook_user_seed'

desc "This tasks shows test user"
task :create_notifications => :environment do
  Experience.where('code <> 3 ').each do |experience|
    ExperiencesBusiness.create_experience(experience)
  end

end
