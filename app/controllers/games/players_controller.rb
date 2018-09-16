class Games::PlayersController < ApplicationController
	include GamesHelper
	before_action :correct_business_or_user_to_see,   only: [:index]

	def index
		@reservation = Reservation.new
		@game = Game.find(params[:id])
		@game_line = GameLine.new

		if params[:game_line]
			gl = GameLine.find(params[:game_line])
			gl.update(accepted: "Accepted")
			flash[:success] = "You are confirmed for this game!"
			redirect_to game_path(gl.game)
			if gl.user == current_user
			    Notification.create(recipientable: gl.game.user, actorable: current_user, 
			            action: "Confirmed", notifiable: gl.game)
			end
		end
	end
end