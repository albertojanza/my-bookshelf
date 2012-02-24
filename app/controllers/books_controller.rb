class BooksController < ApplicationController


  def index

  end

  def show
    if params[:asin]
      @book = Book.find_by_asin params[:asin]
    else
      @book = Book.find_by_permalink params[:id]
      #@friends_have_read_it = User.find_all_by_uid((@book.cache_people_have_read & current_user.friends)) if logged_in?
      if logged_in?
        friend_ids = current_user.friends.map {|friend|  friend['id']}
        readers = @book.cache_people_are_reading + @book.cache_people_have_read
        @friends_have_read_it = readers.select{ |user| friend_ids.include?(user[:uid])  }
      end
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

  def friends_bookcase
    @user = current_user
    @friends = current_user.friends
    @reading = current_user.friends_reading
    @book_list = current_user.experiences_and_books_cache
  end

  def bookcase
    @user = User.find_by_id params[:id]
    @read_books = @user.experiences.where('code = 0').order('updated_at DESC').includes(:book)
    @reading = @user.experiences.where('code = 1').order('updated_at DESC').includes(:book)
    @next_books = @user.experiences.where('code = 2').order('updated_at DESC').includes(:book)
    @recommended_books = @user.experiences.where('code = 3').order('updated_at DESC').includes(:book).includes(:recommender)
    @book_list = current_user.experiences_and_books_cache unless @user.eql? current_user
  end

  def shelf
    @user = User.find params[:id]
    if (params[:code].eql? 3)
      @books = @user.experiences.where('code = 3').includes(:book).includes(:recommender)
    else
      @books = @user.experiences.where('code = ?',params[:code]).order('updated_at DESC').includes(:book)
    end
    @book_list = current_user.experiences_and_books_cache unless @user.eql? current_user

  end


  #def bookcase_read_books
  #  @user = User.find params[:id]
  #  @books = @user.experiences.where('code = 0').order('updated_at DESC').includes(:book)
  #  render 'bookcase'
  #end
  #
  #def bookcase_reading_books
  #  @user = User.find params[:id]
  #  @books = @user.experiences.where('code = 0').order('updated_at DESC').includes(:book)
  #  render 'bookcase'
  #end

  #def bookcase_next_books
  #  @user = User.find params[:id]
  #  @books = @user.experiences.where('code = 2').order('updated_at DESC').includes(:book)
  #  render 'bookcase'
  #end

  #def bookcase_recommended_books
  #  @user = User.find params[:id]
  #  @books = @user.experiences.where('code = 3').includes(:book).includes(:recommender)
  #  render 'bookcase'
  #end
  

end
