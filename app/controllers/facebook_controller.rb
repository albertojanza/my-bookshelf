class FacebookController < ApplicationController

  def friend_list
    user = User.find params[:id]
    @friends = user.friends
    @friends_in = User.where(' token is not NULL').find_all_by_uid user.friends.map{|friend| friend['id']}
    #@friends_out = (@friends.select {|friend| @friends_in.map{|friend_in| friend_in.uid }.include?(friend['id'])}) || []
    @friends_out = @friends.select {|friend| !@friends_in.map{|friend_in| friend_in.uid }.include?(friend['id'])}

  end

  def send_dialog
    redirect_to "http://www.facebook.com/dialog/send?app_id=#{ENV['FACEBOOK_KEY']}&to=#{params[:uid]}&display=page&name=Libroshelf&link=http://www.libroshelf.com/&redirect_uri=http://localhost:3000/response"

  end

end
