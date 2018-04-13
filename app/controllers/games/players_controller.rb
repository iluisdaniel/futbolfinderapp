class Games::PlayersController < ApplicationController
	include GamesHelper
	before_action :correct_business_or_user_to_see,   only: [:index]

	def index
		@game = Game.find(params[:id])
		@game_line = GameLine.new

		if params[:game_line]
			gl = GameLine.find(params[:game_line])
			gl.update(accepted: "Accepted")
			flash[:success] = "You are confirmed for this game!"
			redirect_to game_path(gl.game)
		end
	end
end