class Games::OldGamesController < ApplicationController
	before_action :signed_in_business_or_user?, only: :index
	
	def index
		@games = Game.old_reservations(current_business_or_user)
	end

end