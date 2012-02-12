class BooksController < ApplicationController


  def index

  end

  def show
    @book = Book.find_by_permalink params[:id]
    @friends_have_read_it = User.find_all_by_uid((@book.people_have_read & current_user.friends)) if logged_in?
    #@friends_have_read_it = ((@book.people_have_read & current_user.friends)) if logged_in?
  end

  def search
client = ASIN::Client.instance
@books = client.search(:Keywords => params[:title], :SearchIndex => :Books,:ResponseGroup => [:Images,:ItemAttributes])

  #render :index

  end

  def friends_bookshelf
    @friends = current_user.friends
    @reading = current_user.friends_reading
  end

  def bookshelf
    @user = User.find_by_id params[:id]
    @read_books = @user.books.where('code = 0')
    @reading = @user.books.where('code = 1')
    @next_books = @user.books.where('code = 2')
    @recommended_books = @user.books.where('code = 3')
  end

  def bookcase_read_books
    @user = User.find params[:id]
    @books = @user.books.where('code => 0')
    render 'bookcase'
  end
  
  def bookcase_reading_books
    @user = User.find params[:id]
    @books = @user.books.where('code => 0')
    render 'bookcase'
  end

  def bookcase_next_books
    @user = User.find params[:id]
    @books = @user.books.where('code => 2')
    render 'bookcase'
  end

  def bookcase_recommended_books
    @user = User.find params[:id]
    @books = @user.books.where('code => 3')
    render 'bookcase'
  end
  

end
