class InteractionsController < ApplicationController
  before_filter :login_required

  def notifications

    @news_count = NotificationsBusiness.news_notifications_count current_user.id
    @reco_count = NotificationsBusiness.reco_notifications_count current_user.id
    @items = NotificationsBusiness.get_news_notifications current_user.id
  end

  def recommendations

    @news_count = NotificationsBusiness.news_notifications_count current_user.id
    @reco_count = NotificationsBusiness.reco_notifications_count current_user.id
    @items = NotificationsBusiness.get_reco_notifications current_user.id
  end

  def reset_count
    case params[:count] 
      when 'news'
        NotificationsBusiness.reset_news_notifications_count current_user.id
      when 'reco'
        NotificationsBusiness.reset_reco_notifications_count current_user.id
    end
    FbRequestsBusiness.remove_requests  current_user.token, current_user.id
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
