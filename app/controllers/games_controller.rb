class GamesController < ApplicationController
	before_action :signed_in_business_or_user?, only: [:index, :show]
	include GamesHelper

	def index
		@user = current_user
		@business = current_business
		if @business != nil
			@games = Game.where(business_id: @business)
		elsif @user !=nil
			@games = Game.where(user_id: @user)
		end
	end

	def show
		@game = Game.find(params[:id])

		if logged_in? 
			@business = current_business
		
			if !(@business.id == @game.business_id)
				@game = nil
				redirect_to games_path
			end
		end

		if signed_in?
				@user = current_user

				if !(@user.id == @game.user_id)
					@game = nil
					redirect_to games_path
				end
		end		
	end

	def new
		@game = Game.new
	end

	def create
		@game = Game.new(game_params)		
		if @game.save
			redirect_to games_path
			flash[:success] = "Game was created"
		else
			render 'new'
		end
	end

	private

	def game_params
		params.require(:game).permit(:date, :time, :user_id, :business_id, :field_id, :end_time)
	end
end
