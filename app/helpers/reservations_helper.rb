module ReservationsHelper

	def correct_business_to_see
    	 res = current_business.reservations.find_by(id: params[:id])
	      redirect_to root_url if res.nil?	
    end

    def get_reservation_user(reservation)
    	if reservation.game.nil?
    		return "N/A"
    	end

    	return reservation.game.user.name
    end

end
