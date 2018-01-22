class SelectGameController < ApplicationController
	before_action :signed_in_user_but_not_business?, only: :index

	def index
		if params[:date]
			@games_no_res = Game.without_reservation(current_user)
		end
	end
	

end
