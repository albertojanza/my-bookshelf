
class Archive
  @queue = :file_serve

  def self.perform(email, name, content)

    ContactMail.contact_message(email, name, content).deliver
  end
end

