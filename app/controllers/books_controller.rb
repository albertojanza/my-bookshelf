class BooksController < ApplicationController


  def index

  end

  def show
    @book = Book.find_by_permalink params[:id]
  end

  def search
client = ASIN::Client.instance
@books = client.search(:Keywords => params[:title], :SearchIndex => :Books,:ResponseGroup => [:Images,:ItemAttributes])

  #render :index

  end

  def friends_bookshelf
    @user = User.find session[:user_id]
    @friends = @user.friends
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
