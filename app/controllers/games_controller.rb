class GamesController < ApplicationController
	include GamesHelper
	before_action :signed_in_business_or_user?, only: [:index, :show, :new, :create, :destroy]
	before_action :correct_business_or_user_to_see,   only: [:show]
	before_action :correct_business_or_user_to_delete, only: [:destroy]
	before_action :set_fields_collection, only: [:new, :create]
	before_action :set_businesses_collection, only: [:new, :create]

	def index
		@user = current_user
		if logged_in?
			@games = current_business.games.order(created_at: :desc)
		elsif signed_in?
			@games = Game.joins(game_lines: :user).where(game_lines: {user_id: current_user.id}).order(created_at: :desc)
		end
	end

	def show
		@game = Game.find(params[:id])
		@game_lines = @game.game_lines
		@game_line = GameLine.new	
	end

	def new
		#TODO: FIx fields from form when there is an error
		@game = Game.new
	end

	def create
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

		if @game.save
			redirect_to games_path
			flash[:success] = "Game was created"
			GameLine.create(user_id: @game.user_id, game_id: @game.id)
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
		params.require(:game).permit(:date, :time, :user_id, :business_id, :field_id, :end_time)
	end

	def find_user_with_email(email)
		user = User.find_by(email: email)
		return user
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

	def get_available_field(business_id, game)
		fields = Field.where(business_id: business_id)

		fields.each do |f|
			game[:field_id] = f.id

			return f.id if game.valid?
		end
	end

end
