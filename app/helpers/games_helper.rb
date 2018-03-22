module GamesHelper
	def correct_business
	      game = current_business.games.find_by(id: params[:id])
          redirect_to root_url if game.nil?
    end

    def correct_user_to_see(game)
    	game_line = current_user.game_lines.find_by(game_id: params[:id])

        # Check if current user is  admin, is on the game list, or is allow to see by public setting.
		if (game.user_id != current_user.id && game_line.nil?) && !is_allow_to_see_from_game_public_setting?(game)
	      redirect_to root_url 
	  	end	
    end

    def is_allow_to_see_from_game_public_setting?(game)
        if game.public == "Public"
            return true
        elsif game.public == "Friends"
            if game.user.is_a_friend?(current_user)
                return true
            end
        elsif game.public == "Friends of friends"
            if game.user.is_a_friend?(current_user) || game.user.is_a_friend_of_a_friend?(current_user)
                return true
            end
        end
        return false               
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

    #simplify this method. 
    def correct_business_or_user_to_edit_page
        if logged_in?
            g = current_business.games.find_by(id: params[:id])
            if !g.nil?
                return true
            end
        elsif signed_in?
             game = current_user.games.find_by(id: params[:id])

             if !game.nil?
              return true
            end 
        else
            return false
        end
    end

    def correct_business_or_user_to_see
    	game = Game.find_by(id: params[:id])

        if game.public == "Public"
            return true
        else
            if logged_in?
        		correct_business
        	elsif signed_in?
        		correct_user_to_see(game)
        	else
        		return false
        	end  
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
    	elsif signed_in?
            
    		game = current_user.games.find_by(id: game_line.game_id)

    		if game_line.user_id == current_user.id
    			correct_user = true
    		end
        else
            return false
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
            return user.first_name
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
            return game.user.first_name
        end

        if !game.business.nil?
            return game.business.name
        end

        return
    end

    def get_game_from_params
        Game.find(params[:game])
    end

    
    def get_venue_date
        if session[:res_date]
            session[:res_date]
        elsif params[:date]
                params[:date]
        elsif params[:custom_venue]
            CustomVenue.find(params[:custom_venue]).date
        end 
    end

    def get_venue_time
        if session[:res_time]
            session[:res_time]
        elsif params[:time]
                params[:time]
        elsif params[:custom_venue]
            CustomVenue.find(params[:custom_venue]).time.strftime("%H:%M")
        end 
    end

    def get_venue_name
        if session[:res_business_id]
            Business.find(session[:res_business_id]).name
        elsif params[:business]
            Business.find(params[:business].to_i).name
        end
    end

    def get_venue_address
        # if id.is_a? String
        #     Business.find(session[:res_business_id])
        # else
        #     Business.find(params[:business].keys[0].to_i)
        # end
        if session[:res_business_id]
            Business.find(session[:res_business_id]).address
        elsif params[:custom_venue]
            CustomVenue.find(params[:custom_venue]).address
            elsif params[:business]
            Business.find(params[:business]).address
        end       
    end

    def get_venue_city
        if session[:res_business_id]
            Business.find(session[:res_business_id]).city
        elsif params[:custom_venue]
            CustomVenue.find(params[:custom_venue]).city
            elsif params[:business]
            Business.find(params[:business]).city
        end  
    end

    def get_venue_state
        if session[:res_business_id]
            Business.find(session[:res_business_id]).state
        elsif params[:custom_venue]
            CustomVenue.find(params[:custom_venue]).state
            elsif params[:business]
            Business.find(params[:business]).state
        end  
    end

    def get_venue_zipcode
        if session[:res_business_id]
            Business.find(session[:res_business_id]).zipcode
        elsif params[:custom_venue]
            CustomVenue.find(params[:custom_venue]).zipcode
            elsif params[:business]
            Business.find(params[:business]).zipcode
        end  
    end

    def get_field_venue
        if session[:res_field_id]
            Field.find(session[:res_field_id])
        elsif params[:field]
            Field.find(params[:field])
        end
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
            return "https://s3-us-east-2.amazonaws.com/futfinder.com/soccer-game.png"
        when 1 
            return "https://s3-us-east-2.amazonaws.com/futfinder.com/soccer-field-background.png"
        when 2
            return "https://s3-us-east-2.amazonaws.com/futfinder.com/soccer-field.png"
        else    
            return "https://s3-us-east-2.amazonaws.com/futfinder.com/soccer-ball-field.png"
        end
    end

    def get_user_from_comment(user_id)
        u = User.find(user_id)
        return u
    end

    def user_has_avatar?(user_id)
         u = User.find(user_id)

         if u.avatar_file_name.nil? 
            return false
         end
         return true
    end

    def get_invites_real_string(invites)
        if invites 
            return "Allowed"
        else
            return "Not Allowed"
        end
    end

end
