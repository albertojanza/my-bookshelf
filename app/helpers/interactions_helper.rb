module InteractionsHelper

  def notification_message(item)
    message = ''
    message << link_to(item['user_name'],bookcase_path(:id => item['user_id'] ) )

  end

end
