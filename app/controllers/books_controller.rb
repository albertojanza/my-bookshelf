class BooksController < ApplicationController


  def show
    @book = Book.find_by_permalink params[:id]
  end

  def search
client = ASIN::Client.instance
@books = client.search(:Keywords => params[:title], :SearchIndex => :Books,:ResponseGroup => [:Images,:ItemAttributes])

  #render :index

  end

end
