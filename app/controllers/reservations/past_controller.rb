class Reservations::PastController < ApplicationController
	before_action :signed_in_business, only: :index
	
	def index
		@reservations = current_business.reservations.past
	end

end