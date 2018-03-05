class GamesController < ApplicationController
	include GamesHelper
	before_action :signed_in_business_or_user?, only: [:index, :show, :new, :create,:edit, :update, :destroy]
	before_action :correct_business_or_user_to_see,   only: [:show]
	before_action :correct_business_or_user_to_delete, only: [:edit, :update,:destroy]
	before_action :set_businesses_collection, only: [:show]
	before_action :set_fields_collection, only: [:show]

	@@res = Hash.new
	@@reservation_creation_message = ""

	def index
		# add field id
		#FIX displaying same day games in games and not in old games
		# TODO: Maybe, include game status ex: planning, ready, complete?
		@games = Game.with_reservation(current_business_or_user)
		@games_no_reservation = Game.without_reservation(current_business_or_user)	
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
		@game_line = GameLine.new
		#Bug - when a field is erased from a business, and the show action is called it fails because it cannot find field to show field info into the show page
		# Make impossible to erase a field in the case there are open games. Or it has to erased all of them. 
		@reservation = Reservation.new
		@custom_venue = CustomVenue.new

		if params[:date]
			@@res = {date: params[:date], time: Time.zone.parse(params[:time]), end_time: Time.zone.parse(params[:time]) + 1.hour, 
				business: params[:business].to_i, field: params[:field].to_i}
			@@reservation_creation_message = "Reservation created"
			check_reservation(true)	
		end
		
	end

	def new
		#TODO: How to choose businesses field. 
		@game = Game.new
		if params[:date]
			@@res = {date: params[:date], time: Time.zone.parse(params[:time]), end_time: Time.zone.parse(params[:time]) + 1.hour, 
				business: params[:business].to_i, field: params[:field].to_i}
				@@reservation_creation_message = "Game and Reservation created"
		end
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

		if logged_in?
			@game = current_business.games.build(game_params)
			user =  find_user_with_email(game_params[:user_id])
			if !user.nil?
				@game[:user_id] = user.id
			end	
		end

		if signed_in?
			@game = current_user.games.build(game_params)
		end

		if @game.save				
			redirect_to @game
			flash[:success] = "Your Game Was Created"		
			if !@game.user_id.nil?
				gl = GameLine.new(user_id: @game.user_id, game_id: @game.id, invited_by: nil)
				gl.save
				gl = @game.game_lines.first.update(accepted: "Accepted")
			end
			check_reservation(false)
		else
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
		@game.destroy
		flash[:success] = "Game destroyed"
		redirect_to games_path
	end
	

	private

	def game_params
		params.require(:game).permit(:user_id, :business_id, :number_players, :title, 
			:description, :public, :invite_allowed)
	end

	def check_reservation(redirect)
		if !@@res.empty?
				reservation = Reservation.new(date: @@res[:date], time: @@res[:time], end_time: @@res[:end_time],
					business: Business.find(@@res[:business]), field_id: @@res[:field], game: @game)
				if reservation.save
					if redirect == true
						redirect_to @game
					end
					flash[:success] = @@reservation_creation_message
					Notification.create(recipientable: reservation.business, actorable: current_user, 
					                action: "Made", notifiable: reservation)
				else
					#TODO: Show error message. Why is failing?
					flash[:warning] = "could't make reservation"
				end
				@@res.clear
				@@reservation_creation_message = ""
		end
	end

end