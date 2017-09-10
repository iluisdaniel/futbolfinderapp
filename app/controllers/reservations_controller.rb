class ReservationsController < ApplicationController
	include GamesHelper
	include ReservationsHelper
	before_action :signed_in_business_or_user?, only: [:index, :show, :new, :create]
	
	before_action :set_fields_collection, only: [:new, :create]
	before_action :set_businesses_collection, only: [:new, :create]
	
	def index 
		rs = current_business.reservations
		@reservations = rs.where("date > ?", Date.today).order(date: :asc)
		@oldreservations = rs.where("date < ?", Date.today).order(date: :desc)
	end

	def show
		@reservation = Reservation.find(params[:id])
		@field = @reservation.business.fields.find(@reservation.field_id)
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
end
