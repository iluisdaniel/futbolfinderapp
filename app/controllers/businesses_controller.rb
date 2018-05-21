class BusinessesController < ApplicationController
  before_action :signed_in_business, only: [:edit, :update, :stripe_connect, :confirmation, :dashboard]
  before_action :redirect_back_when_is_already_logged_in?, only: [:new, :create]
  before_action :correct_business,   only: [:edit, :update]
  before_action :confirm_stripe_account, only: [:edit, :update, :confirmation]
  before_action :redirect_back_if_stripe_already_created, only: :stripe_connect

  
  def index
    @businesses = Business.paginate(page: params[:page], per_page:  15)
  end

  def show
  	@business = Business.friendly.find(params[:id])
  end

  def new
  	@business = Business.new
  end

  def create
  	@business = Business.new(business_params)
  	if@business.save
  		log_in @business
      # flash[:success] = "Welcome to Futbol Finder!"
  		# redirect_to new_subscription_path(plan: "monthly19")
      redirect_to b_stripe_connect_path
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
    @charges = current_business.charges.where(reservation_id: nil, user_id: nil)
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

  def stripe_connect
    require 'net/http'

    if params[:code]
      # flash[:success] = params[:code]

      uri = URI.parse("https://connect.stripe.com/oauth/token")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri.request_uri)
      request.set_form_data({"client_secret" => Rails.application.secrets.stripe_private_key, 
                            "code" => params[:code], "grant_type" => 'authorization_code'})
      response = http.request(request)
    
        if response.body.empty?
        # Show the user an error message
        flash[:danger] = "error"
        else
          res = JSON.parse response.body

           if !res['stripe_user_id'].nil?
              # flash[:info] = res
              # save this to business table res['stripe_user_id']
              current_business.save_stripe_acct_id(res['stripe_user_id'])
              redirect_to b_confirmation_path
           else
              flash[:danger] = res['error'] + ", " + res['error_description']
           end     
        end
      end 
    end

    def confirmation
    end

    def dashboard
      @reservations = current_business.reservations.order(date: :desc, time: :desc).limit(10)
      # flash[:info] = Date.parse("12-04-2018").day

      @charges_amount = get_todays_charges_amount

      @notifications = Notification.where(recipientable: current_business_or_user).order(created_at: :desc).limit(5)
    end 

  private

    def business_params
    	params.require(:business).permit(:name, :email, :phone, :address, :city, :state, :zipcode, :password, 
    										:password_confirmation,:avatar)
    end

    def redirect_back_if_stripe_already_created
      if !current_business.stripe_user_id.nil?
        redirect_to root_path
      end
    end

    def confirm_stripe_account
      if current_business.stripe_user_id.nil?
        redirect_to b_stripe_connect_path
      end
    end

    # Confirms the correct user.
    def correct_business
      @business = Business.friendly.find(params[:id])
      redirect_to(root_url) unless current_business?(@business)
    end

    def get_todays_charges_amount
      # d = Date.parse("12-05-2018")
      d = Date.current - 1.day
      # d = Date.current - 1.day
      charges = current_business.charges.where(status: "Successful", created_at: d.beginning_of_day..d.end_of_day)
      # flash[:info] = charges.count
      amount = 0
      charges.each do |c|
        amount = amount + c.amount
      end 
      amount / 100 
    end

end
