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
    @user = current_user
    @friends = current_user.friends
    @reading = current_user.friends_reading
  end

  def bookshelf
    @user = User.find_by_id params[:id]
    @read_books = @user.experiences.where('code = 0').includes(:book)
    @reading = @user.experiences.where('code = 1').includes(:book)
    @next_books = @user.experiences.where('code = 2').includes(:book)
    @recommended_books = @user.experiences.where('code = 3').includes(:book).includes(:recommender)
  end

  def bookcase_read_books
    @user = User.find params[:id]
    @books = @user.experiences.where('code => 0').includes(:book)
    render 'bookcase'
  end
  
  def bookcase_reading_books
    @user = User.find params[:id]
    @books = @user.experiences.where('code => 0').includes(:book)
    render 'bookcase'
  end

  def bookcase_next_books
    @user = User.find params[:id]
    @books = @user.experiences.where('code => 2').includes(:book)
    render 'bookcase'
  end

  def bookcase_recommended_books
    @user = User.find params[:id]
    @books = @user.experiences.where('code => 3').includes(:book).includes(:recommender)
    render 'bookcase'
  end
  

end
