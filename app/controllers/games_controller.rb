class GamesController < ApplicationController
	include GamesHelper
	before_action :signed_in_business_or_user?, only: [:index, :show, :new, :create,:edit, :update, :destroy]
	before_action :correct_business_or_user_to_see,   only: [:show]
	before_action :correct_business_or_user_to_delete, only: [:edit, :update,:destroy]
	before_action :set_businesses_collection, only: [:show]
	before_action :set_fields_collection, only: [:show]

	def index
		# add field id
		#FIX displaying same day games in games and not in old games
		if logged_in?
			gs = current_business.games
			# @games = gs.where("date > ?", Date.today).order(date: :asc)
			# @oldgames = gs.where("date < ?", Date.today).order(date: :desc)
		elsif signed_in?
			gs = Game.joins(game_lines: :user).where(game_lines: {user_id: current_user.id})	
			# @games = gs.where("date > ?", Date.today).order(date: :asc)
			# @oldgames = gs.where("date < ?", Date.today).order(date: :desc)
			# User.includes(:posts).references(:posts).where('posts.id IS NULL')
		end
		@games = gs.includes(:reservation).references(:reservation)
					.where('reservations.id IS NOT NULL AND reservations.date > ?', Time.now)
					.order("reservations.date asc")
		@games_no_reservation = gs.includes(:reservation).references(:reservation).where('reservations.id IS NULL')
		
		@oldgames = gs.includes(:reservation).references(:reservation)
					.where('reservations.id IS NOT NULL AND reservations.date < ?', Time.now)
					.order("reservations.date desc")
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

		@game = Game.find(params[:id])
		@game_lines = @game.game_lines.where(accepted: false)
		@game_lines_accepted = @game.game_lines.where(accepted: true)
		@game_line = GameLine.new
		@reservation = Reservation.new
		#Bug - when a field is erased from a business, and the show action is called it fails because it cannot find field to show field info into the show page
		# Make impossible to erase a field in the case there are open games. Or it has to erased all of them. 

		if @game.public == true
			@isPublic = "Public"
		else
			@isPublic = "Private"
		end	
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

		@game[:title] = set_game_title(@game.title)
		@game[:description] = set_game_description(@game.description)

		if @game.save				
			redirect_to @game
			flash[:success] = "Your Game Was Created"		
			if !@game.user_id.nil?
				GameLine.create(user_id: @game.user_id, game_id: @game.id, accepted: true)
			end
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

	def search
		# Search on business index
		# <div class="row">
		# 	<div class="">
		# 	</div>
		# 	<div class="col-md-5">
		# 	<%= form_tag search_path, action: "search", method: :get, class: "form-group pull-right" do %>
		# 		<div class="input-group">
		# 			<%= text_field_tag :city, params[:city], placeholder: "Search",  class: "form-control pull-left" %>
		# 			<span class="input-group-addon"><span class="glyphicon glyphicon-search"></span>
		# 		</div>	
		# 		<%= submit_tag "Search",name: nil, class: "btn btn-primary btn-fill pull-right" %>
		# 	<% end %>
		# 	</div>
		# </div>
		# <hr>

		# results = Array.new
		# results = find_available_fields(params[:city], params[:time], params[:number])
		@businesses = find_available_fields(params[:city], params[:time], params[:number])

		if @businesses.empty?
			flash.now[:warning] = @message
		end
	end

	private

	def game_params
		params.require(:game).permit(:user_id, :business_id, :number_players, :title, 
			:description, :public)
	end

	def set_game_title(title)
		
		if title.nil? || title.empty?
			return "Game " + current_business.name
		end

		return title
	end




	def set_game_description(desc)
		if desc.nil? || desc.empty?
			w = "by"

			if signed_in?
				w = "at"
			end

			return "Your game has been created " + w + " "+ current_business.name + ". Enjoy your game!. Your are welcome to change this descrition and let the other players what's up"
		end

		return desc
	end

end
