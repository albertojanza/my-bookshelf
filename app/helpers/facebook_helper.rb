module FacebookHelper

  def profile_picture_url(uid)
    "#{request.ssl? ? 'https' : 'http'}://graph.facebook.com/#{uid}/picture"
  end

  def facebook_locale
    locale = 'en_US'
    if logged_in?
     locale = current_user.locale || 'en_US' 
    elsif !request.env["HTTP_ACCEPT_LANGUAGE"].nil?
      spanish = request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
      locale = 'es_LA'  if spanish.eql? 'es'
    end
    locale      
  end

end
