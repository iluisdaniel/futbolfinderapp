class Games::PlayersController < ApplicationController

	def index
		@game = Game.find(params[:id])
		@game_line = GameLine.new
	end
end