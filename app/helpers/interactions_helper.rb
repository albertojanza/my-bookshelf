module InteractionsHelper

  def notification_message(item)
    message = ''
    case item['code'].to_i
      when 0
        message <<  I18n.t('noti_read_book_html', :name => link_to(item['user_name'],bookcase_path(:id => item['user_id'])), :title => link_to(item['title'],book_path(:id => item['book_id']))).html_safe
      when 1
        message <<  I18n.t('noti_reading_book_html', :name => link_to(item['user_name'],bookcase_path(:id => item['user_id'])), :title => link_to(item['title'],book_path(:id => item['book_id'])),:author => by_authors(JSON.parse(item['author']))).html_safe
      when 2
        message <<  I18n.t('noti_next_book_html', :name => link_to(item['user_name'],bookcase_path(:id => item['user_id'])), :title => link_to(item['title'],book_path(:id => item['book_id'])),:author => by_authors(JSON.parse(item['author']))).html_safe
      when 3
        message <<  I18n.t('noti_recommendation_book_html', :recommender => link_to(item['recommender_name'],bookcase_path(:id => item['recommender_id'])), :name => link_to(item['user_name'],bookcase_path(:id => item['user_id'])), :title => link_to(item['title'],book_path(:id => item['book_id'])),:author => by_authors(JSON.parse(item['author']))).html_safe
    end
    message

  end


  def recommendation_message(item)
     I18n.t('reco_book_html', :recommender => link_to(item['recommender_name'],bookcase_path(:id => item['recommender_id'])), :title => link_to(item['title'],book_path(:id => item['book_id'])),:author => by_authors(JSON.parse(item['author']))).html_safe
  end


end
