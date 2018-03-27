class ReservationsController < ApplicationController
	include GamesHelper
	include ReservationsHelper
	before_action :signed_in_user, only: :confirmation
	before_action :signed_in_business, only: [:index, :show, :edit, :update]
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
			# @reservation[:field_id] = get_available_field(@reservation[:business_id], @reservation)
			@reservation[:end_time] =  @reservation[:time] + 1.hour
		end

		if params[:source]

		end
			

		if @reservation.save
			if logged_in?
				redirect_to @reservation
			elsif signed_in?
				game = get_game(@reservation.game_id)
				redirect_to game
				game.game_lines.uniq.each do |gl|
				    if gl.user != current_user
				        Notification.create(recipientable: gl.user, actorable: current_user, 
				                action: "reserved a field", notifiable: game)
				    end
				end
				Notification.create(recipientable: @reservation.business, actorable: current_user, 
				                action: "Made", notifiable: @reservation)
			end
			
			flash[:success] = "Reservation created succesfully"
		else
			render 'new'
			flash[:danger] = @reservation.errors.full_messages.to_s
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
		game = @reservation.game
		@reservation.destroy
		flash[:success] = "Reservation was deleted"
		define_redirection(game)
		# TODO - figure out a way to show res cancellations from users
		if !game.nil? 
			game.game_lines.uniq.each do |gl|
				    if gl.user != current_user
				        Notification.create(recipientable: gl.user, actorable: current_business_or_user, 
				                action: "cancelled a reservation", notifiable: game)
				    end
				end
			# Notification.create(recipientable: @reservation.business, actorable: current_user, 
			# 	                action: "Cancelled", notifiable: @reservation)
		end
	end

	def confirmation
		@reservation = Reservation.new
	end

	def check_in
		@reservation = Reservation.find(params[:id])
		if @reservation.update(check_in_time: DateTime.current)
			flash[:success] = "Reservation updated"
		  redirect_to @reservation
		else
		  flash[:warning] = "Please try again"
		  redirect_to @reservation
		end

	end

	# def confirmed
	# 	if params[:date]
	# 		b = params[:business].to_
	# 		d = params[:date].to_s
	# 		t = Time.zone.parse(params[:time].to_s)
	# 		et = Time.zone.parse(params[:time].to_s) + 1.hour
	# 		f = (params[:field].to_s).to_i
	# 		g = (params[:games].to_s).to_i
	# 		params = ActionController::Parameters.new({ 
	# 				res: {
	# 					business_id: b, 
	# 					date: d, 
	# 					time: t, 
	# 					end_time: et, 
	# 					field_id: f, 
	# 					game_id: g
	# 				} 
	# 			})
	# 		permitted = params.require(:res).permit(:date, :time, :end_time, :business_id, 
	# 		:field_id, :game_id)
	# 		res = Reservation.new(permitted)
	# 		if res.save	
	# 			flash[:success] = "Game and Reservation created"
	# 			redirect_to res.game
	# 		else
	# 			flash[:danger] = "error" + res.errors.full_messages.to_s + "5555"+params.to_s
	# 			redirect_to available_fields_path(game: params[:game])
	# 		end
	# 	end
	# end


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

    def define_redirection(game)
    	if logged_in?
    		redirect_to reservations_path
    	elsif !game.nil?
    		redirect_to game_path(game)
    	else
    		redirect_to root_path
    	end
    end

end
