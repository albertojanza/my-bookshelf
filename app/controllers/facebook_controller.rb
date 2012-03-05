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
    redirect_to "http://www.facebook.com/dialog/send?app_id=#{ENV['FACEBOOK_KEY']}&to=#{params[:uid]}&display=page&name=#{params[:name]}&link=#{params[:link]}&redirect_uri=#{facebook_dialog_response_url}"

  end

  def dialog_response
    redirect_to session[:return_to]
  end

end
