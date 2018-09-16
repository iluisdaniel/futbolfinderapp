class GamesController < ApplicationController
	include GamesHelper
	# before_action :signed_in_business_or_user?, only: [:index, :new, :create,:edit, :update, :destroy]
	before_action :signed_in_user, only: [:index, :new, :create,:edit, :update, :destroy]
	before_action :correct_business_or_user_to_see,   only: [:show]
	before_action :correct_business_or_user_to_delete, only: [:edit, :update,:destroy]

	def index
		# add field id
		#FIX displaying same day games in games and not in old games
		# TODO: Maybe, include game status ex: planning, ready, complete?
		@games = Game.withReservationOrVenue(current_business_or_user, params[:page])
		if (params[:date] && !params[:date].empty?)
			@games = Game.searchWithReservationOrVenue(current_business_or_user, params[:date], params[:page])
		elsif params[:status] == "Invited"
			@games = Game.get_invited_ones(current_user, params[:page])
		elsif params[:status] == "Completed"
			@games = Game.old_reservations_or_custom_venues(current_business_or_user, params[:page])
		elsif params[:status] == "Planning"
			@games = Game.without_reservation(current_business_or_user, params[:page])
		else
			@games = Game.withReservationOrVenue(current_business_or_user, params[:page])
		end

		if @games.empty?
			if params[:invited]
				@msg = "You don't have any invitations pending at the moment."
			elsif params[:date] || params[:current] || params[:public]
				@msg = "Sorry, we couldn't find any games"
			elsif params[:status]
					@msg = "You don't have any planning games at this moment"
			else
				@msg = "You don't have any games at this moment"
			end
		end
	end

	def show
		# TODO: Dont show comment form for people who is not part of the game. 
		# maybe when the game is public, the admin should accept the players?. Or admin could erased and blocked users. 
		# - Have the option for admins in the game to make other players admin?
		# - if the player exit the game, make another player the admin. 
		# - Use emails or usernames to invite people
		#-show rules or guidelines for the business 
		# make game lines accepted able to change accepted true to false, instead of delete them
		#- when user creates the game business cannot edit and see the title
		# when games are old people cant edit the game, and business only games they create themselves. 
		# users can set alerts in case a filed got reserved on a time. Maybe, choose prefered place and time and if another users reserved they get an alert. 
		#use bootstrap h1 predertemined header
		@game = Game.find(params[:id])
		@reservation = Reservation.new
		#Bug - when a field is erased from a business, and the show action is called it fails because it cannot find field to show field info into the show page
		# Make impossible to erase a field in the case there are open games. Or it has to erased all of them. 
	end

	def new
		#TODO: How to choose businesses field. 
		@game = Game.new
	end

	def create

		#TODO
		#- look user with phone as well. 
		#- Improve showing validation of email or phone 
		#- when there is an error, field of email shows id instead of email
		#- Add custom address
		#- add random 6 digit id for games
		#- sanitize inputs
		# if user is nil, that means it is a public pickup game created by the business, if user doesnt have an account, create an accoun from its email and name
		# add button to create games from modal
		#  show notes when business is going to create the game 
		# user cannot reserve two games at the same date


		# if logged_in?
		# 	@game = current_business.games.build(game_params)
		# end

		@game = current_user.games.build(game_params)

		# if params[:time]
		# 	flash[:success] = params[:time].values[1] 
		# 	flash[:info] = params[:date] 
		# 	params[:time] = nil
		# end

		if (params[:date] && !params[:date].empty?) && 
			(!params[:time].values[0].empty?)
			date = Date.strptime(params[:date], '%m/%d/%Y')
			time = DateTime.new(date.year,date.month,date.day,params[:time].values[0].to_i ,params[:time].values[1].to_i , 0, "-0400")
			@reservation = Reservation.new(time: time, end_time: time + (params[:duration].to_f).hour)
		end


		if !@reservation.nil? && @reservation.valid? && @game.save
			# redirect_to available_fields_path(game: @game)
			 flash[:success] = "Game created!"
			redirect_to @game

			@reservation.game = @game
			@reservation.save

			if !@game.user_id.nil?
				gl = GameLine.new(user_id: @game.user_id, game_id: @game.id, invited_by: nil)
				gl.save
				gl = @game.game_lines.first.update(accepted: "Accepted")
			end
		else
			if @reservation.nil? 
				flash[:danger] = "Please choose a correct date and time"
			elsif !@reservation.valid?
				flash[:danger] = @reservation.errors.full_messages.first.to_s
			else
				flash[:danger] = @game.errors.full_messages.first.to_s
			end
			params[:time] = nil
			render 'new'
		end

		
	end

	def edit
		@game = Game.find(params[:id])
	end

	def update
		@game = Game.find(params[:id])

		if @game.update_attributes(game_params)
		  flash[:success] = "Game updated"
		  redirect_to @game
		else
		  render 'edit'
		end
	end

	def destroy
		@game = Game.find(params[:id])
		if @game.reservation
			flash[:danger] = "Please cancel your reservation first."
			redirect_to @game
		else
			@game.game_lines.uniq.each do |gl|
				    if gl.user != current_user
				        Notification.create(recipientable: gl.user, actorable: current_business_or_user, 
				                action: "cancelled", notifiable: @game)
				    end
			end
			@game.destroy
			flash[:success] = "Game destroyed"
			redirect_to games_path

		end
	end
	

	private

	def game_params
		params.require(:game).permit(:user_id, :business_id, :number_players, :title, 
			:description, :public, :invite_allowed)
	end

	# def check_reservation(redirect)
	# 	if session[:res_business_id]
				
	# 			reservation = Reservation.new(date: session[:res_date].to_s, time: Time.zone.parse(session[:res_time]), end_time: Time.zone.parse(session[:res_time]) + 1.hour,
	# 				business: Business.find((session[:res_business_id].to_s).to_i), field_id: session[:res_field_id].to_i, game: @game)
	# 			# flash[:info] = reservation

	# 			# if reservation.valid?
	# 			# 	reservation.errors.full_messages.each do |e|
	# 			# 		flash[:warning] = e.to_s
	# 			# 	end 
	# 			# end

	# 			if reservation.save
	# 				if redirect == true
	# 					flash[:success] = "Reservation created"
	# 					redirect_to @game
	# 				else
	# 					flash[:success] = "Game and Reservation created"
	# 				end
					
	# 				Notification.create(recipientable: reservation.business, actorable: current_user, 
	# 				                action: "Made", notifiable: reservation)
	# 			else
	# 				#TODO: Show error message. Why is failing?
	# 				flash[:warning] = "could't make reservation"
	# 			end
	# 			session[:res_business_id] = nil
	# 			session[:res_field_id] = nil
	# 			session[:res_date] = nil
	# 			session[:res_time] = nil
	# 			session[:res_end_time] = nil
	# 	end

	# end

end