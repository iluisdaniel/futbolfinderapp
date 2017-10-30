class Games::TodayController < ApplicationController
	before_action :signed_in_business_or_user?, only: :index
	
	def index
		@games = Game.today_games_with_reservations(current_business_or_user)
	end

end