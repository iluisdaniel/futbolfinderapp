class ReservationsController < ApplicationController
	include GamesHelper
	include ReservationsHelper
	before_action :signed_in_business, only: [:index, :show, :new, :edit, :update]
	before_action :signed_in_business_or_user?, only: [:create, :destroy]
	before_action :correct_user_or_business_to_destroy, only: [:destroy]
	before_action :correct_business_res, only: [:show, :edit, :update]
	before_action :set_fields_collection, only: [:new, :create, :edit, :update]
	before_action :set_businesses_collection, only: [:new, :create]
	
	def index 
		#Upcoming - Show now, and next reservations
		# Recently created by user
		# todays view and possibility to change to another date
		# past reservations
		## Create a view for fields. Where shows the avility of the field on that date. 
		@reservations = current_business.reservations.current
		@oldreservations = current_business.reservations.past
	end

	def show
		@reservation = Reservation.find(params[:id])
	end

	def new 
		@reservation = Reservation.new
	end

	def create
		# fix redirection when businesses create reservations from games
		if logged_in?
			@reservation = current_business.reservations.build(reservation_params)
		elsif signed_in?
			@reservation = Reservation.new(reservation_params)
			@reservation[:field_id] = get_available_field(@reservation[:business_id], @reservation)
		end
			

		if @reservation.save
			if logged_in?
				redirect_to @reservation
			elsif signed_in?
				redirect_to get_game(@reservation.game_id)
			end
			
			flash[:success] = "Reservation created succesfully"
		else
			render 'new'
		end
	end

	def edit
		@reservation = Reservation.find(params[:id])
	end

	def update
		@reservation = Reservation.find(params[:id])

		if @reservation.update_attributes(reservation_params)
		  flash[:success] = "Reservation updated"
		  redirect_to @reservation
		else
		  render 'edit'
		end
	end

	def destroy
		# improve redirection part for users
		@reservation = Reservation.find(params[:id])
		@reservation.destroy
		flash[:success] = "Reservation was deleted"
		define_redirection
	end

	private

	def reservation_params
		params.require(:reservation).permit(:date, :time, :end_time, :business_id, 
			:field_id, :game_id)
	end

	def get_available_field(business_id, reservation)
		fields = Field.where(business_id: business_id)

		fields.each do |f|
			reservation[:field_id] = f.id
			return f.id if reservation.valid?
		end
	end

	def correct_user_or_business_to_destroy
		if logged_in?
    		correct_business_res
    	elsif signed_in?
    		correct_user_res
    	else
    		return false
    	end
	end

    def correct_business_res
	      res = current_business.reservations.find_by(id: params[:id])
          redirect_to root_url if res.nil?
    end

    def correct_user_res
    	res = Reservation.find_by(id: params[:id])
    	user = res.game.user
    	redirect_to root_url if current_user != user
    end

    def define_redirection
    	if logged_in?
    		redirect_to reservations_path
    	elsif signed_in?
    		redirect_to games_path
    	else
    		redirect_to root_path
    	end
    end

end
