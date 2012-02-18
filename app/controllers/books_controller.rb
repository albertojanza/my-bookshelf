class BooksController < ApplicationController


  def index

  end

  def show
    if params[:asin]
      @book = Book.find_by_asin params[:asin]
    else
      @book = Book.find_by_permalink params[:id]
      @friends_have_read_it = User.find_all_by_uid((@book.people_have_read & current_user.friends)) if logged_in?
    end
    #@friends_have_read_it = ((@book.people_have_read & current_user.friends)) if logged_in?
  end

  def search
    client = ASIN::Client.instance
    @books = client.search(:Keywords => params[:title], :SearchIndex => :Books,:ResponseGroup => [:Images,:ItemAttributes])
    @book_list = current_user.experiences_and_books_cache
    respond_to do |format|
      format.html 
    #  format.json  
    end

  end

  def friends_bookshelf
    @user = current_user
    @friends = current_user.friends
    @reading = current_user.friends_reading
    @book_list = current_user.experiences_and_books_cache
  end

  def bookshelf
    @user = User.find_by_id params[:id]
    @read_books = @user.experiences.where('code = 0').order('updated_at DESC').includes(:book)
    @reading = @user.experiences.where('code = 1').order('updated_at DESC').includes(:book)
    @next_books = @user.experiences.where('code = 2').order('updated_at DESC').includes(:book)
    @recommended_books = @user.experiences.where('code = 3').order('updated_at DESC').includes(:book).includes(:recommender)
  end

  def bookcase_read_books
    @user = User.find params[:id]
    @books = @user.experiences.where('code = 0').order('updated_at DESC').includes(:book)
    render 'bookcase'
  end
  
  def bookcase_reading_books
    @user = User.find params[:id]
    @books = @user.experiences.where('code = 0').order('updated_at DESC').includes(:book)
    render 'bookcase'
  end

  def bookcase_next_books
    @user = User.find params[:id]
    @books = @user.experiences.where('code = 2').order('updated_at DESC').includes(:book)
    render 'bookcase'
  end

  def bookcase_recommended_books
    @user = User.find params[:id]
    @books = @user.experiences.where('code = 3').includes(:book).includes(:recommender)
    render 'bookcase'
  end
  

end
