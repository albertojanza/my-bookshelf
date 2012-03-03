class UsersController < ApplicationController

  def account
    @user = current_user
    render 'communication_settings'
  end


  def communication_form
    @user = current_user
    @user.fb_read_communication = ( params[:read] ? true : false)
    @user.fb_reading_communication = (params[:reading] ? true : false)
    @user.fb_next_communication = ( params[:next] ? true : false)
    @user.save
    @message = (@user.errors.any? ? I18n.t('communication_error_message') : I18n.t('message'))
    render 'communication_settings'
  end

end
