class Games::UpcomingGamesController < ApplicationController
	
	def index
		@games = Game.with_reservation(current_business_or_user)
	end

end