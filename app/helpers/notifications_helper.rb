module NotificationsHelper

    def get_name_from_actionable(n)
        if n.actorable.class.to_s == "Business"
            return n.actorable.name
        elsif n.actorable.class.to_s == "User"
            return n.actorable.first_name
        end
                
    end

	def get_right_icon_name(n)
        if n.notifiable.class.to_s == "Game"
            if n.action == "Commented"
            	return "comment"
            elsif n.action == "reserved a field" || n.action == "cancelled a reservation"
            	return "calendar"
            end
            return "soccer-ball-o"
        elsif n.notifiable.class.to_s == "Reservation"
        	return "calendar"
        elsif n.notifiable.class.to_s == "Friendship"
            return "user-plus"    
        end
     end

     def get_actorable_path(n)
     	if n.actorable.class.to_s == "User"
     		return user_path(n.actorable)
     	elsif n.actorable.class.to_s == "Business"
     		return business_path(n.actorable)
     	end
     end

     def get_notifiable_path(n)
     	if n.notifiable.class.to_s == "Game"
     		return game_path(n.notifiable)
     	elsif n.notifiable.class.to_s == "Reservation"
     		return reservation_path(n.notifiable)
     	end
     end

     def get_new_if_no_read(n)
     	if n.read_at.nil? == true
     		return "New"
     	end

     	return 
     end

     def get_rest_of_the_setence(n)
     	if n.action == "Invited You"
     		return " to a "
     	elsif n.action == "Removed You"
     		return " from a "
     	elsif n.action == "Made"
     		return " a "
        elsif n.action == "Added You"
                return " as a "
        elsif n.action == "Accepted Your"
            return ""
     	else
     		return " in a "	
     	end
     end

     def get_friendship_notification_words(n)

        if n.action == "Added You"
            return "friend"
        elsif n.action == "Accepted Your"
            "friend request"
        end
         
     end
     
end