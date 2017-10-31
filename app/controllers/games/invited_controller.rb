class Games::InvitedController < ApplicationController
	before_action :signed_in_user_but_not_business?, only: :index
	
	def index
		@games = Game.get_invited_ones_with_res(current_user)
		@games_no_date = Game.get_invited_ones_without_res(current_user)
	end

end