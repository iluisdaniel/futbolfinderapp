module ReservationsHelper

	def correct_business_to_see
    	 res = current_business.reservations.find_by(id: params[:id])
	      redirect_to root_url if res.nil?	
    end

    def get_reservation_user(reservation)
    	if reservation.game.nil?
    		return current_business.name
    	end

        if reservation.game.user.nil?
            return current_business.name
        end

    	return reservation.game.user.name
    end

     def is_at_one_of_index_reservations?
        if current_page?(controller: '/reservations/past', action: 'index') 

            return true
        end

        return false

    end

end
