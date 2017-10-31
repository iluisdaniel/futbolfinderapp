class Games::PlanningController < ApplicationController
	before_action :signed_in_business_or_user?, only: :index
	
	def index
		@games = Game.without_reservation(current_business_or_user)
	end

end