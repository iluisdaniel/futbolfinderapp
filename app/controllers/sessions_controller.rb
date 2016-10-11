class SessionsController < ApplicationController
  
  def new
  end

  def create
  	business = Business.find_by(email: params[:session][:email].downcase)
    user = User.find_by(email: params[:session][:email].downcase)
  	if business && business.authenticate(params[:session][:password])
  		log_in business
  		params[:session][:remember_me] == '1' ? remember(business) : forget(business)
  		redirect_back_or business
  	elsif user && user.authenticate(params[:session][:password])
      sign_in user
      redirect_back_or user
    else	
  		flash.now[:danger] = 'Invalid email/password combination' 
  		render 'new'
  	end
  end

  def destroy
  	sign_out if signed_in?
    log_out if logged_in?
  	redirect_to root_url
  end
end
