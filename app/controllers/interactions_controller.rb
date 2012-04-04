class InteractionsController < ApplicationController
  before_filter :login_required

  def notifications
    @count = InteractionsDao.notifications_count(current_user.id)
    @items = InteractionsDao.get_notifications(current_user.id)
  end


private 

  def similarities_book
    if current_user.books.empty?
      @last_book = Book.last
    else 
      @last_book = current_user.books.last
    end
  end



end
