class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user, :logged_in? #, :redirect_to_target_or_default

  http_basic_authenticate_with :name => ENV['HTTP_USER'], :password => ENV['HTTP_PASSWORD']


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

end
