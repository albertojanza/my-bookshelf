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

  def bookshelf
    user = User.find_by_username params[:username]
    @read_books = user.experiences
  end

end
