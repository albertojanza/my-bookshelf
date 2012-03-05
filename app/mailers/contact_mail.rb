class ContactMail < ActionMailer::Base
  default from: "contact@libroshefl.com"


 def contact_message(email,name,message)
    @email = email 
    @name = name
    @message = message
    mail(:to => ['bertojanza@gmail.com','contact@libroshelf.com'], :subject => "Libroshelf")
  end

end
