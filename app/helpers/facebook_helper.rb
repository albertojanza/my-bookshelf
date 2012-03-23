module FacebookHelper

  def profile_picture_url(uid)
    "#{request.ssl? ? 'https' : 'http'}://graph.facebook.com/#{uid}/picture"
  end

end
