class Games::UpcomingGamesController < ApplicationController
	before_action :signed_in_business_or_user?, only: :index
	
	def index
		@games = Game.this_week_games_with_reservation(current_business_or_user)
		@tomorrow_games = Game.tomorrow_games_with_reservations(current_business_or_user)
		@games_no_date = Game.without_reservation(current_business_or_user)
	end

end