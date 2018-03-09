class StaticPagesController < ApplicationController
  
  def home
  	if signed_in?
  		redirect_to games_path
  	elsif logged_in?
  		redirect_to root_path
  	else
  		redirect_to login_path
  	end

  end

  def help
  end

  def about
  end
end
