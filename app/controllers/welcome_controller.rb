require "base64"

class WelcomeController < ApplicationController
  ########before_filter :required_logged_in, :only => :canvas 

  def index

    unless logged_in?
      # TODO take a look at the landing layout, if it is not useful remove it
      #render :landing, :layout => 'landing'
      render :landing, :layout => 'landing'

    else 

    @user = current_user
    @friends = current_user.friends
    @reading = current_user.friends_reading
    @book_list = current_user.experiences_and_books_cache
    @last_book = last_book([@reading])
    render 'books/friends_bookcase'

    #@user = User.find_by_id(current_user.id) 
    #@read_books = @user.experiences.where('code = 0').order('updated_at DESC').includes(:book)
    #@reading = @user.experiences.where('code = 1').order('updated_at DESC').includes(:book)
    #@next_books = @user.experiences.where('code = 2').order('updated_at DESC').includes(:book)
    #@recommended_books = @user.experiences.where('code = 3').order('updated_at DESC').includes(:book).includes(:recommender)
    #@book_list = current_user.experiences_and_books_cache unless @user.eql? current_user
    #@last_book = last_book([@recommended_books, @read_books, @next_books, @reading])
    #render 'books/bookcase'

    end

  end

  def timeline
    @experiences = current_user.experiences()
  end

  def canvas
    #Facebook sends a parameter to the canvas url every time that they invoke this url. Two different cases
    # If the user has allowed access to the app then Facebook sends the user_id
    # If the user is a new user for the app, Facebook sends a little information about the user: country and language
    if false # params[:signed_request]
      encoded_sig, payload = params[:signed_request].split('.')
      user_data =ActiveSupport::JSON.decode base64_url_decode(payload)
      if user_data['user_id']
        authentication = Authentication.find_by_provider_and_uid('facebook', user_data['user_id'])
        # The next line doesnt work, because the previous call to logged_in? method already set up the @current_user variable.
        #session[:user_id] = authentication.user.id
        self.current_user=(authentication.user)
      else
        render :text =>  "<script> top.location.href='https://www.facebook.com/dialog/oauth?client_id=#{ENV['FACEBOOK_KEY']}&redirect_uri=#{canvas_callback_url}&scope=publish_actions,publish_stream'</script>"
      end
    end

      render :landing, :layout => 'landing'
  

  end

private


  def last_book(bookshelves)
    book = nil
    bookshelves.each do |bookshelf|
      book = bookshelf.first unless bookshelf.empty?
    end
    book
  end
  


end
