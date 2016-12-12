class BusinessesController < ApplicationController
  before_action :signed_in_business, only: [:edit, :update]
  before_action :correct_business,   only: [:edit, :update]
  
  def index
    @businesses = Business.all
  end

  def show
  	@business = Business.friendly.find(params[:id])
    @schedules = @business.schedules.all
    @fields = @business.fields.all
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
    @fields = @business.fields.all
    @schedule = Schedule.new
    @field = Field.new
  end

  def update
    @business = Business.friendly.find(params[:id])
    @schedules = @business.schedules.all
    @fields = @business.fields.all
    @schedule = Schedule.new
    @field = Field.new
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

    # Confirms the correct user.
    def correct_business
      @business = Business.friendly.find(params[:id])
      redirect_to(root_url) unless current_business?(@business)
    end


end
