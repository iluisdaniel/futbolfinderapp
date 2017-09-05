class GamesController < ApplicationController
	include GamesHelper
	before_action :signed_in_business_or_user?, only: [:index, :show, :new, :create, :destroy]
	before_action :correct_business_or_user_to_see,   only: [:show]
	before_action :correct_business_or_user_to_delete, only: [:destroy]
	before_action :set_fields_collection, only: [:new, :create]
	before_action :set_businesses_collection, only: [:new, :create]

	def index
		# add field id
		if logged_in?
			gs = current_business.games.order(created_at: :desc)
			@games = gs.where("date > ?", Date.today)
			@oldgames = gs.where("date < ?", Date.today)
		elsif signed_in?
			gs = Game.joins(game_lines: :user).where(game_lines: {user_id: current_user.id}).order(created_at: :desc)
			@games = gs.where("date > ?", Date.today)
			@oldgames = gs.where("date < ?", Date.today)
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

		@game = Game.find(params[:id])
		@game_lines = @game.game_lines.where(accepted: false)
		@game_lines_accepted = @game.game_lines.where(accepted: true)
		@game_line = GameLine.new
		#Bug - when a field is erased from a business, and the show action is called it fails because it cannot find field to show field info into the show page
		# Make impossible to erase a field in the case there are open games. Or it has to erased all of them. 
		@field = @game.business.fields.find(@game.field_id)

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
			@b = current_business
			@game[:business_id] = @b.id
			user =  find_user_with_email(game_params[:user_id])
			if !user.nil?
				@game[:user_id] = user.id
			end	
		end

		if signed_in?
			@game = current_user.games.build(game_params)
			@u = current_user
			@game[:user_id] = @u.id
			@game[:field_id] = get_available_field(@game[:business_id], @game)
		end

		@game[:title] = set_game_title(@game.title, @game.business.name, @game.date, @game.time)
		@game[:description] = set_game_description(@game.description, @game.business.name)

		if @game.save				
			redirect_to @game
			flash[:success] = "Your Game Was Created"		
			if !@game.user_id.nil?
				GameLine.create(user_id: @game.user_id, game_id: @game.id)
			end
		else
			render 'new'
		end
	end

	def destroy
		@game.destroy
		redirect_to root_path
	end

	def search
		# results = Array.new
		# results = find_available_fields(params[:city], params[:time], params[:number])
		@businesses = find_available_fields(params[:city], params[:time], params[:number])

		if @businesses.empty?
			flash.now[:warning] = @message
		end
	end

	private

	def game_params
		params.require(:game).permit(:date, :time, :user_id, :business_id, 
			:field_id, :end_time, :number_players, :title, :description, :public)
	end


	def set_fields_collection
		if logged_in?
			@fields = current_business.fields
		end
	end

	def set_businesses_collection
		if signed_in?
			@businesses = Business.all
		end
	end

	def set_game_title(title, location, date, time)
		if title.nil? || title.empty?
			return "Game at " + location + ". " + date.strftime("%B %e") + ", " + time.strftime("%I:%M %p") + "."
		end
		return title
	end

	def set_game_description(desc, location)
		if desc.nil? || desc.empty?
			w = "by"

			if signed_in?
				w = "at"
			end

			return "Your game has been created " + w + " "+ location  + ". Enjoy your game!. Your are welcome to change this descrition and let the other players what's up"
		end

		return desc
	end

	def get_available_field(business_id, game)
		fields = Field.where(business_id: business_id)

		fields.each do |f|
			game[:field_id] = f.id

			return f.id if game.valid?
		end
	end

end
