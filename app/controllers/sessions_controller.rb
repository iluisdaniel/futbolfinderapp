class SessionsController < ApplicationController
  
  def new
  end

  def create
  	business = Business.find_by(email: params[:session][:email].downcase)
  	if business && business.authenticate(params[:session][:password])
  		log_in business
  		params[:session][:remember_me] == '1' ? remember(business) : forget(business)
  		redirect_back_or business
  	else	
  		flash.now[:danger] = 'Invalid email/password combination' 
  		render 'new'
  	end
  end

  def destroy
  	log_out if logged_in?
  	redirect_to root_url
  end
end
