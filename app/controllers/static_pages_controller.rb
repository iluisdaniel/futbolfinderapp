class StaticPagesController < ApplicationController
  
  def home
  	if signed_in?
  		redirect_to games_path
  	elsif logged_in?
      redirect_to dashboard_path
  	else
  		@coming_soon = true
      @launching_email = LaunchingEmail.new
  	end

  end

  def help
  end

  def about
  end
end
