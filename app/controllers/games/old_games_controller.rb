class Games::OldGamesController < ApplicationController
	
	def index
		@games = Game.old_reservations(current_business_or_user)
	end

end