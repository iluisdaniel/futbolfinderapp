class Games::PlayersController < ApplicationController
	include GamesHelper
	before_action :correct_business_or_user_to_see,   only: [:index]

	def index
		@game = Game.find(params[:id])
		@game_line = GameLine.new
	end
end