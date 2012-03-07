


class ApplicationController < ActionController::Base
  rescue_from User::TokenExpiration, :with => :ouath_process
  protect_from_forgery
  before_filter :set_locale
  before_filter :ensure_domain



  helper_method :current_user, :logged_in? #, :redirect_to_target_or_default

  def ensure_domain
    if request.env['HTTP_HOST'] != 'libroshelf.com' && Rails.env.production? 
      # HTTP 301 is a "permanent" redirect
      redirect_to "http://libroshelf.com", :status => 301
    end
  end



  def set_locale

    if !session[:locale].nil? 
      # User has a current session.
      I18n.locale = session[:locale]
    elsif logged_in?
      if I18n.available_locales.include? current_user.locale.scan(/^[a-z]{2}/).first.to_sym
        I18n.locale =  current_user.locale.scan(/^[a-z]{2}/).first.to_sym
      else
        I18n.locale =   I18n.default_locale
      end
      session[:locale] = I18n.locale
    elsif !request.env["HTTP_ACCEPT_LANGUAGE"].nil?
      I18n.locale = request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
      session[:locale] = I18n.locale
    else
      I18n.locale = I18n.default_locale
      session[:locale] = I18n.locale
    end
  end
 

#  def required_logged_in
#    unless logged_in?
#  @encoded_sig, @payload = params[:signed_request].split('.')
#   @facebook_params =ActiveSupport::JSON.decode base64_url_decode(@payload)
#
##   @facebook_params =ActiveSupport::JSON.decode base64_url_decode(params[:signed_request])
#
#    #render :inline =>  "<script> top.location.href='http://graph.facebook.com/oauth/authorize?client_id=#{ENV['FACEBOOK_KEY']}&redirect_uri=#{facebook_callback_url}&scope=publish_actions,publish_stream'</script>" # 
#if @facebook_params['user_id']
#    authentication = Authentication.find_by_provider_and_uid('facebook', @facebook_params['user_id'])
#    # The next line doesnt work, because the previous call to logged_in? method already set up the @current_user variable.
#    #session[:user_id] = authentication.user.id
#    self.current_user=(authentication.user)
#
#    logger.info('AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABBBBBBBBBBBBBBBBBBBBBBBBB')  if logged_in?
#    logger.info('BBBBBBBBBBBBBBBBBBBAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABBBBBBBBBBBBBBBBBBBBBBBBB')  unless logged_in?
#end
#    #render :text =>  "<script> top.location.href='https://www.facebook.com/dialog/oauth?client_id=#{ENV['FACEBOOK_KEY']}&redirect_uri=#{facebook_callback_url}&scope=publish_actions,publish_stream'</script>"
#    render "/welcome/canvas"
#  end
  #end

 def base64_url_decode(str)
   str += '=' * (4 - str.length.modulo(4))
   Base64.decode64(str.tr('-_','+/'))
 end





  def logged_in?
      current_user != :false
  end


  # Accesses the current user from the session.
  # Future calls avoid the database because nil is not equal to false.
  def current_user
     #@current_user ||= (login_from_session || login_from_cookie || :false)
     @current_user ||= (login_from_session  || :false)
  end


  # Store the given user id in the session.
  def current_user=(new_user)
    session[:user_id] = new_user ? new_user.id : nil
    @current_user = new_user || :false
  end


  def login_from_session
     self.current_user = User.find_by_id(session[:user_id]) if session[:user_id]
  end


#  def login_from_cookie
#     user = cookies[:auth_token] && User.find_by_remember_token(cookies[:auth_token])
#     if user && user.remember_token? && !user.remember_token_expires_at.nil? && Time.now < user.remember_token_expires_at
#       self.current_user = user
#     end
#  end

  def login_required
    unless logged_in?
#      store_target_location
#      redirect_to login_url, :alert => "You must first log in or sign up before accessing this page."
      redirect_to root_path
    end
  end
private

  def ouath_process
    respond_to do |format| 
      format.html { redirect_to "http://graph.facebook.com/oauth/authorize?client_id=#{ENV['FACEBOOK_KEY']}&redirect_uri=#{facebook_callback_url}&publish_stream" }
      format.js { render :inline =>  " top.location.href='http://graph.facebook.com/oauth/authorize?client_id=#{ENV['FACEBOOK_KEY']}&redirect_uri=#{facebook_callback_url}&publish_stream';" }
    end 
    
  end
end
