class WelcomeController < ApplicationController
  def index
  end

  def search
client = ASIN::Client.instance
@books = client.search(:Keywords => params[:title], :SearchIndex => :Books)

  render :index

  end

end
