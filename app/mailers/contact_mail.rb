class ContactMail < ActionMailer::Base
  default from: "contact@libroshefl.com"


 def contact_message(email,name,message)
    @email = email 
    @name = name
    @message = message
    mail(:to => ['bertojanza@gmail.com','contact@libroshelf.com'], :subject => "Libroshelf")
  end

 def error_message(email,exception,user,request)
    @user = user
    @request = request
    @email = email 
    @exception = exception
    mail(:to => ['error@libroshelf.com'], :subject => exception.message )
  end

end
