class BooksController < ApplicationController

  before_filter :login_required, :only => [:show_friends,
                                           :shelf,
                                           :bookcase]



  def index

  end

  def show
    if params[:asin]
      @book = Book.find_by_asin params[:asin]
    else
      @book = Book.find_by_permalink params[:id]
      #@friends_have_read_it = User.find_all_by_uid((@book.cache_people_have_read & current_user.friends)) if logged_in?
    end
    @reviews = @book.reviews.order('updated_at DESC').includes(:user)
    if logged_in?
      friend_ids = current_user.friends.map {|friend|  friend['id']}
      readers = @book.cache_people_are_reading + @book.cache_people_have_read +  @book.cache_people_will_read + @book.cache_people_with_recommendations
      @friends_have_read_it = readers.select{ |user| friend_ids.include?(user[:uid])  }
      @experience = Experience.find_by_user_id_and_book_id(@current_user.id,@book.id)
      @friends_reviews = @reviews.select{ |review| friend_ids.include?(review.user.uid) ||  review.user.uid.eql?(current_user.uid)}
      @reviews = @reviews - @friends_reviews
    end
    #@friends_have_read_it = ((@book.people_have_read & current_user.friends)) if logged_in?
  end

  def show_friends
    @book = Book.find params[:id]
    @friends = []
    @friends_with_experience = []
    uid_people_have_read = @book.cache_people_have_read.map{|user| user[:uid]}
    uid_people_are_reading = @book.cache_people_are_reading.map{|user| user[:uid]}
    uid_people_will_read = @book.cache_people_will_read.map{|user| user[:uid]}
    uid_people_with_recommendations = @book.cache_people_with_recommendations.map{|user| user[:uid]}
    current_user.friends.each do |friend| 
      if uid_people_have_read.include?(friend['id']) || uid_people_are_reading.include?(friend['id'])  || uid_people_will_read.include?(friend['id']) || uid_people_with_recommendations.include?(friend['id']) 
        @friends_with_experience << friend
      else
        @friends << friend
      end
    end
  end


  def search
    client = ASIN::Client.instance
    @books = client.search(:Keywords => params[:title], :SearchIndex => :Books,:ResponseGroup => [:Images,:ItemAttributes])
    @book_list = current_user.experiences_and_books_cache if logged_in?
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
    @last_book = last_book([@reading])
  end

  def bookcase
    @user = User.find_by_id params[:id]
    @read_books = @user.experiences.where('code = 0').order('updated_at DESC').includes(:book)
    @reading = @user.experiences.where('code = 1').order('updated_at DESC').includes(:book)
    @next_books = @user.experiences.where('code = 2').order('updated_at DESC').includes(:book)
    @recommended_books = @user.experiences.where('code = 3').order('updated_at DESC').includes(:book).includes(:recommender)
    @book_list = current_user.experiences_and_books_cache unless @user.eql? current_user
    @last_book = last_book([@recommended_books, @read_books, @next_books, @reading])
  end

  def shelf
    @user = User.find params[:id]
    if (params[:code].eql? 3)
      @books = @user.experiences.where('code = 3').includes(:book).includes(:recommender)
    else
      @books = @user.experiences.where('code = ?',params[:code]).order('updated_at DESC').includes(:book)
    end
    @last_book = last_book([@books])
    @book_list = current_user.experiences_and_books_cache unless @user.eql? current_user

  end

  def sidebar_similarities
    @book = Book.find_by_asin params[:asin]
    @similarities = @book.similarities
    render :partial => 'widget_similarities',:layout => nil
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
private

# Array with a list of bookshelves, the method returns the book in the last bookshelf that is not empty
  def last_book(bookshelves)
    book = nil
    bookshelves.each do |bookshelf|
      book = bookshelf.first unless bookshelf.empty?
    end
    book
  end
  

end
