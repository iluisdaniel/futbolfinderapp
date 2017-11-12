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

    def are_there_games?
      if signed_in?
          if current_user.games_involved.count == 0 
              return false
          end
       elsif logged_in?
          if current_business.games.count == 0 
            return false
          end
      end
      return true   
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

    def get_reservation_month_and_day_from_game(game_id)
        g = Game.find(game_id)
        if g.reservation.nil?
            return "N/A"
        else
            return g.reservation.date.strftime("%^b %d")
        end
    end

    def get_reservation_time_from_game(game_id)
        g = Game.find(game_id)
        if g.reservation.nil?
            return "N/A"
        else
            return g.reservation.time.strftime("%l:%M %p")
        end
    end

    def get_reservation_end_time_from_game(game_id)
        g = Game.find(game_id)
        if g.reservation.nil?
            return "N/A"
        else
            return g.reservation.end_time.strftime("%l:%M %p")
        end
    end

     def get_reservation_location_from_game(game_id)
        g = Game.find(game_id)
        if g.reservation.nil?
            return "N/A"
        else
            return g.reservation.business
        end
    end

    def get_number_of_players_ready(game_id)
        g = Game.find(game_id)
        return g.game_lines.where(accepted: true).count
    end

    def public_or_private(public)
        if public == true
            return "Public"
        end
        return "Private"
    end

    def get_game_creator(game)
        if !game.user.nil?
            return game.user
        end

        if !game.business.nil?
            return game.business
        end

        return
    end

    def get_public_or_private_string_from_game
        if @game.public == true
            return "Public"
        else
            return "Private"
        end 
    end

    def is_at_one_of_index_games?
        if current_page?(controller: '/games/upcoming_games', action: 'index') ||
            current_page?(controller: '/games/planning', action: 'index')  ||
            current_page?(controller: '/games', action: 'index') ||
            current_page?(controller: '/games/old_games', action: 'index') ||
            current_page?(controller: '/games/invited', action: 'index')

            return true
        end

        return false
    end

    def get_random_background_image
        random = rand(4)
        case random
        when 0
            return "/assets/soccer-game"
        when 1 
            return "/assets/soccer-field-background"
        when 2
            return "/assets/soccer-field"
        else    
            return "/assets/soccer-ball-field"
        end
    end


end
