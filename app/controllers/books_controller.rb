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
    user = User.find_by_id params[:id]
    @read_books = user.experiences.where(:code => 0)
    @reading = user.experiences.where(:code => 1)
    @next_books = user.experiences.where(:code => 2)
    @recommendations = user.experiences.where(:code => 3)
    @friends = user.friends

  end

end
