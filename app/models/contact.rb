class Contact < ActiveRecord::Base
 validates :name, :presence => true
  validates :email, :presence => true, :format => {:with => /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/, :message => 'is not looking good'}
  validates :content, :presence => true

  after_create :deliver_email

  def deliver_email
    ContactMail.contact_message(self.email, self.name, self.content).deliver
  end

end
