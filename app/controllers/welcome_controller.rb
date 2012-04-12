require "base64"

class WelcomeController < ApplicationController
  ########before_filter :required_logged_in, :only => :canvas 



# if the user clicks on the link that appears on the sidebar: 3 teaching requests:
#   "fb_source"=>"request", "request_ids"=>"334362366620410,225363117571571,325535667501147", "ref"=>"reminders"
# if the user clicks on the link that appears on the bookmark 
#  "fb_source"=>"bookmark_apps", "ref"=>"bookmarks", "count"=>"1", "fb_bmpos"=>"1_1"
#  "fb_source"=>"bookmark_apps", "ref"=>"bookmarks", "count"=>"2", "fb_bmpos"=>"1_2"
# if the user clicks on a specific request
# , "fb_source"=>"request", "request_ids"=>"334362366620410"
# if the user clicks on a notification
# , "fb_source"=>"notification", "request_ids"=>"334362366620410"

# /canvas/?fb_source=notification&request_ids=391335190897861%2C309126179160146%2C387641201255925%2C329580493763964%2C216406055131367%2C305169186221299%2C429862177028249
#                     &ref=notif&app_request_type=user_to_user&notif_t=app_request
# /canvas/?fb_source=notification&request_ids=391335190897861%2C309126179160146%2C387641201255925%2C329580493763964%2C216406055131367%2C305169186221299%2C429862177028249%2C332448606816604&
#                     ref=notif&app_request_type=user_to_user&notif_t=app_request"
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

######################################################
## Scenarios
## - New user
##      We dont show the canvas page. Since we are a canvas app we ask directly for permissions.
## - A user, the singed_request contains an user_id
##    - The user comes from a notification. We recieve a request id
##        we show the book page. (The notification could be a book recommendation or a notfication that a friend has read the same book)


  def canvas
    #Facebook sends a parameter to the canvas url every time that they invoke this url. Two different cases
    # If the user has allowed access to the app then Facebook sends the user_id
    # If the user is a new user for the app, Facebook sends a little information about the user: country and language
    # {"algorithm"=>"HMAC-SHA256", "issued_at"=>1332263157, "user"=>{"country"=>"us", "locale"=>"es_LA", "age"=>{"min"=>21}}}
      if params[:signed_request]
        encoded_sig, payload = params[:signed_request].split('.')
        user_data =ActiveSupport::JSON.decode base64_url_decode(payload)
        if user_data['user_id'] && (user = User.find_by_provider_and_uid('facebook', user_data['user_id']))
          # The next line doesnt work, because the previous call to logged_in? method already set up the @current_user variable.
          #session[:user_id] = authentication.user.id
          self.current_user=(user)

          # The user has clicked on a notification or a request, so we know which one we have to show him
          @experiences = FbRequestsBusiness.process_request(params['request_ids'], params['fb_source'], user.token, user.uid)  if params['request_ids'] 
          ###################################################################
          # DUPLICATED CODE IN books controller action friends_bookcase
          ###################################################################
          @user = current_user
          @friends = current_user.friends
          @reading = current_user.friends_reading
          @book_list = current_user.experiences_and_books_cache
          @last_book = last_book([@reading])
          I18n.locale =  current_user.locale.scan(/^[a-z]{2}/).first.to_sym
          session[:locale] = I18n.locale
          render 'books/friends_bookcase'
        else
          if I18n.available_locales.include? user_data['user']['locale'].scan(/^[a-z]{2}/).first.to_sym
            I18n.locale =  user_data['user']['locale'].scan(/^[a-z]{2}/).first.to_sym
            session[:locale] = I18n.locale
          end
          render :landing, :layout => 'landing'
          #render :text =>  "<script> top.location.href='https://www.facebook.com/dialog/oauth?client_id=#{ENV['FACEBOOK_KEY']}&redirect_uri=#{canvas_callback_url}&scope=publish_actions,publish_stream'</script>"
        end
      else
        render :inline =>  "<script> top.location.href='https://www.facebook.com/dialog/oauth?client_id=#{ENV['FACEBOOK_KEY']}&redirect_uri=#{canvas_callback_url}&scope=publish_actions,email'</script>"
      end

  end




  def canvas_old
    #Facebook sends a parameter to the canvas url every time that they invoke this url. Two different cases
    # If the user has allowed access to the app then Facebook sends the user_id
    # If the user is a new user for the app, Facebook sends a little information about the user: country and language
    # {"algorithm"=>"HMAC-SHA256", "issued_at"=>1332263157, "user"=>{"country"=>"us", "locale"=>"es_LA", "age"=>{"min"=>21}}}
      if params[:signed_request]
        encoded_sig, payload = params[:signed_request].split('.')
        user_data =ActiveSupport::JSON.decode base64_url_decode(payload)
        if user_data['user_id'] && (user = User.find_by_provider_and_uid('facebook', user_data['user_id']))
          # The next line doesnt work, because the previous call to logged_in? method already set up the @current_user variable.
          #session[:user_id] = authentication.user.id
          self.current_user=(user)

          if params['request_ids'] && params['request_ids'].class.eql?(String) # The user has clicked on a notification or a request, so we know which one we have to show him
            ###################################################################
            # DUPLICATED CODE IN books controller action show
            ###################################################################
            render :text => 'hola' 
          else
            ###################################################################
            # DUPLICATED CODE IN books controller action friends_bookcase
            ###################################################################
            @user = current_user
            @friends = current_user.friends
            @reading = current_user.friends_reading
            @book_list = current_user.experiences_and_books_cache
            @last_book = last_book([@reading])
            I18n.locale =  current_user.locale.scan(/^[a-z]{2}/).first.to_sym
            session[:locale] = I18n.locale
            render 'books/friends_bookcase'
          end
        else
          if I18n.available_locales.include? user_data['user']['locale'].scan(/^[a-z]{2}/).first.to_sym
            I18n.locale =  user_data['user']['locale'].scan(/^[a-z]{2}/).first.to_sym
            session[:locale] = I18n.locale
          end
          render :landing, :layout => 'landing'
          #render :text =>  "<script> top.location.href='https://www.facebook.com/dialog/oauth?client_id=#{ENV['FACEBOOK_KEY']}&redirect_uri=#{canvas_callback_url}&scope=publish_actions,publish_stream'</script>"
        end
      else
        render :landing, :layout => 'landing'
      end

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
