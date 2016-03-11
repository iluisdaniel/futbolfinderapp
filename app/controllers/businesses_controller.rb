class BusinessesController < ApplicationController
  
  def show
  	@business = Business.find(params[:id])
  end

  def new
  	@business = Business.new
  end

  def create
  	@business = Business.new(business_params)
  	if@business.save
  		flash[:success] = "Welcome to Futbol Finder!"
  		redirect_to @business
  	else
  		render 'new'
  	end
  end

  private

  def business_params
  	params.require(:business).permit(:name, :email, :phone, :address, :city, :state, :zipcode, :password, 
  										:password_confirmation)
  end

end
