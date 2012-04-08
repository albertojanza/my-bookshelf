class FacebookController < ApplicationController

  def friend_list
    user = User.find params[:id]
    @friends = user.friends
    @friends_in = User.where(' token is not NULL').find_all_by_uid user.friends.map{|friend| friend['id']}
    #@friends_out = (@friends.select {|friend| @friends_in.map{|friend_in| friend_in.uid }.include?(friend['id'])}) || []
    @friends_out = @friends.select {|friend| !@friends_in.map{|friend_in| friend_in.uid }.include?(friend['id'])}

  end

  def send_dialog
    session[:return_to] = request.referer
    redirect_to "http://www.facebook.com/dialog/send?app_id=#{ENV['FACEBOOK_KEY']}&to=#{params[:uid]}&display=page&name=#{params[:name]}&link=#{params[:link]}&redirect_uri=#{facebook_send_dialog_response_url}"

  end

  def send_dialog_response
    redirect_to session[:return_to] if session[:return_to]
    redirect_to root_path unless session[:return_to]
  end

  # Facebook properties
  # app_id, redirect_ri
  # to, filters, exclude_ids
  # max_recipients, 
  # message # invite requests (request to user that are not using libroshelf dont see this message) dont see this message.
  # data # Optional, additional data you may pass for tracking. This will be stored as part of the request objects created. The maximum length is 255 characters.
  # title
  def request_dialog
    session[:return_to] = request.referer
    redirect_to "http://www.facebook.com/dialog/apprequests?app_id=#{ENV['FACEBOOK_KEY']}&message=#{I18n.t('request_dialog_invitation_title')}&to=#{params[:uid]}&display=page&title=#{I18n.t('request_dialog_invitation_title')}&redirect_uri=#{facebook_request_dialog_response_url}"

  end

  def request_dialog_response

    InteractionsDao.track_fb_invitation_request(params[:request],params[:to])
    redirect_to session[:return_to] if session[:return_to]
    redirect_to root_path unless session[:return_to]
  end


end
