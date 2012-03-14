class ContactMail < ActionMailer::Base
  default from: "contact@libroshefl.com"


 def contact_message(email,name,message)
    @email = email 
    @name = name
    @message = message
    mail(:to => ['bertojanza@gmail.com','contact@libroshelf.com'], :subject => "Libroshelf")
  end

 def error_message(email,message,error,user)
    @user = user
    @email = email 
    @message = message
    @error = error
    mail(:to => ['error@libroshelf.com'], :subject =>message )
  end

end
