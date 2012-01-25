class WelcomeController < ApplicationController
  def index

    unless logged_in?

      render :landing, :layout => 'landing'

    end

  end

  def timeline
    @experiences = current_user.experiences()
  end


end
