class FacebookController < ApplicationController

  def friend_list
    user = User.find params[:id]
    @friends = user.friends
    @friends_in = User.where(' token is not NULL').find_all_by_uid user.friends.map{|friend| friend['id']}
    #@friends_out = (@friends.select {|friend| @friends_in.map{|friend_in| friend_in.uid }.include?(friend['id'])}) || []
    @friends_out = @friends.select {|friend| !@friends_in.map{|friend_in| friend_in.uid }.include?(friend['id'])}

  end

end
