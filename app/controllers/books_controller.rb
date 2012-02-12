class BooksController < ApplicationController


  def index

  end

  def show
    @book = Book.find_by_permalink params[:id]
    @friends_have_read_it = Authentication.find_all_by_uid((@book.people_have_read & current_user.friends)) if logged_in?
    #@friends_have_read_it = ((@book.people_have_read & current_user.friends)) if logged_in?
  end

  def search
client = ASIN::Client.instance
@books = client.search(:Keywords => params[:title], :SearchIndex => :Books,:ResponseGroup => [:Images,:ItemAttributes])

  #render :index

  end

  def friends_bookshelf
    @user = User.find session[:user_id]
    @friends = @user.friends
    @reading = @user.friend_reading_experiences
  end

  def bookshelf
    @user = User.find_by_id params[:id]
    @read_books = @user.experiences.where(:code => 0)
    @reading = @user.experiences.where(:code => 1)
    @next_books = @user.experiences.where(:code => 2)
    @recommended_books = @user.experiences.where(:code => 3)
  end

  def bookcase_read_books
    @user = User.find params[:id]
    @books = @user.experiences.where(:code => 0)
    render 'bookcase'
  end
  
  def bookcase_reading_books
    @user = User.find params[:id]
    @books = @user.experiences.where(:code => 0)
    render 'bookcase'
  end

  def bookcase_next_books
    @user = User.find params[:id]
    @books = @user.experiences.where(:code => 2)
    render 'bookcase'
  end

  def bookcase_recommended_books
    @user = User.find params[:id]
    @books = @user.experiences.where(:code => 3)
    render 'bookcase'
  end
  

end
