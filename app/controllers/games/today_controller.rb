class Games::TodayController < ApplicationController
	
	def index
		@games = Game.today_games_with_reservations(current_business_or_user)
	end

end