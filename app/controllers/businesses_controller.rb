class BusinessesController < ApplicationController
  before_action :logged_in_business, only: [:index, :edit, :update]
  before_action :correct_business,   only: [:edit, :update]
  
  def index
    @businesses = Business.all
  end

  def show
  	@business = Business.friendly.find(params[:id])
    @schedules = @business.schedules.all
  end

  def new
  	@business = Business.new
  end

  def create
  	@business = Business.new(business_params)
  	if@business.save
  		log_in @business
      flash[:success] = "Welcome to Futbol Finder!"
  		redirect_to @business
  	else
  		render 'new'
  	end
  end

  def edit
    @business = Business.friendly.find(params[:id])
    @schedules = @business.schedules.all
    @schedule = Schedule.new
  end

  def update
    @business = Business.friendly.find(params[:id])
    @schedules = @business.schedules.all
    @schedule = Schedule.new
    if @business.update_attributes(business_params)
      flash[:success] = "Profile updated"
      redirect_to @business
    else
      render 'edit'
    end
  end

  private

  def business_params
  	params.require(:business).permit(:name, :email, :phone, :address, :city, :state, :zipcode, :password, 
  										:password_confirmation)
  end

  # Confirms a logged-in user.
    def logged_in_business
      unless logged_in?
        store_location
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
    end

    # Confirms the correct user.
    def correct_business
      @business = Business.friendly.find(params[:id])
      redirect_to(root_url) unless current_business?(@business)
    end


end
