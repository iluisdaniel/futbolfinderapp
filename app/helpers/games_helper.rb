module GamesHelper
	def correct_business
	      game = current_business.games.find_by(id: params[:id])
          redirect_to root_url if game.nil?
    end

    def correct_user_to_see
	    game = Game.find_by(id: params[:id])
    	game_line = current_user.game_lines.find_by(game_id: params[:id])

		if (game.user_id != current_user.id && game_line.nil?) && game.public == false
	      redirect_to root_url 
	  	end	
    end

    def correct_user_to_delete
    	 game = current_user.games.find_by(id: params[:id])

    	 if game.nil?
	      redirect_to root_url 
	  	end	
    end

    def correct_business_or_user_to_delete
    	if logged_in?
    		correct_business
    	elsif signed_in?
    		correct_user_to_delete
    	else
    		return false
    	end
    end

    def correct_business_or_user_to_see
    	if logged_in?
    		correct_business
    	elsif signed_in?
    		correct_user_to_see
    	else
    		return false
    	end  		
    end

    def correct_user_for_game_line
    	game_line = current_user.game_lines.find_by(id: params[:id])

    	if game_line.nil?
    		return false
    	end

    	return true
    end

    def is_correct_user_or_business_associated_with_game_line?(game_line)
    	correct_user = false
		
		if logged_in?
			game = current_business.games.find_by(id: game_line.game_id)		
    	else
    		game = current_user.games.find_by(id: game_line.game_id)

    		if game_line.user_id == current_user.id
    			correct_user = true
    		end

    	end

    	if correct_user || !game.nil? 
    		return true
    	end

    	return false
    end

    def find_user_with_email(email)
        user = User.find_by(email: email)
        return user
    end

    def get_user_name_for_comment(id)
        
        if id.nil?
        return "Unknown"
        else
            user = User.find(id)
            return user.name
        end
    end

    def get_field(id)
        if id.nil?
            return 
        end

        if Field.exists?(id)
            field = Field.find(id)
        end

        if !field.nil?
            return field
        end
        
        return 
    end

    def set_fields_collection
        if logged_in?
            @fields = current_business.fields
        end
    end

    def set_businesses_collection
        if signed_in?
            @businesses = Business.all
        end
    end

    def get_game(id)
        g = Game.find(id)
        return g
    end

    def get_reservation_date_from_game(game_id)
        g = Game.find(game_id)
        if g.reservation.nil?
            return "N/A"
        else
            return g.reservation.date.strftime("%D")
        end
    end

    def get_reservation_time_from_game(game_id)
        g = Game.find(game_id)
        if g.reservation.nil?
            return "N/A"
        else
            return g.reservation.time.strftime("%r")
        end
    end

    def get_reservation_end_time_from_game(game_id)
        g = Game.find(game_id)
        if g.reservation.nil?
            return "N/A"
        else
            return g.reservation.end_time.strftime("%r")
        end
    end

     def get_reservation_location_from_game(game_id)
        g = Game.find(game_id)
        if g.reservation.nil?
            return "N/A"
        else
            return g.reservation.business.name
        end
    end

end
