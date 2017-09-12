class ReservationsController < ApplicationController
	include GamesHelper
	include ReservationsHelper
	before_action :signed_in_business, only: [:index, :show, :new, :create, :edit, :update]
	before_action :signed_in_user, only: [:create]
	before_action :set_fields_collection, only: [:new, :create, :edit, :update]
	before_action :set_businesses_collection, only: [:new, :create]
	
	def index 
		rs = current_business.reservations
		@reservations = rs.where("date > ?", Time.now).order(date: :asc)
		@oldreservations = rs.where("date < ?", Time.now).order(date: :desc)
	end

	def show
		@reservation = Reservation.find(params[:id])
	end

	def new 
		@reservation = Reservation.new
	end

	def create
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

	 def correct_business_or_user_to_delete_reservation
    	if logged_in?
    		correct_business
    	elsif signed_in?
    		correct_user_to_delete
    	else
    		return false
    	end
    end

    def correct_business
	      res = current_business.reservations.find_by(id: params[:id])
          redirect_to root_url if res.nil?
    end

    def correct_user_to_delete
    	res = Reservation.find_by(id: params[:id])
    	user = res.game.user
    	redirect_to root_url if current_user != user
    end
end
