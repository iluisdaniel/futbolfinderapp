class Users::UserGamesController < ApplicationController
	before_action :signed_in?, only: :index
	
	def index
		@user = User.friendly.find(params[:id])
		@games = Game.this_week_public_games_with_reservation(@user)
	end
end