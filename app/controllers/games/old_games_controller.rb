class Games::OldGamesController < ApplicationController
	before_action :signed_in_business_or_user?, only: :index
	
	def index
		@games = Game.old_reservations_or_custom_venues(current_business_or_user)
		if params[:date] && !params[:date].empty?
			@games = Game.searchWithReservationOrVenue(current_business_or_user, params[:date])
		else
			@games = Game.old_reservations_or_custom_venues(current_business_or_user)
		end
	end

end