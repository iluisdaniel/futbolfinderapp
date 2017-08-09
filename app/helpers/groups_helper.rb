module GroupsHelper

	def correct_user_to_see_group
	    @group = current_user.groups.find_by(id: params[:id])
    	@group_line = current_user.group_lines.find_by(group_id: params[:id])

		if @group.nil? && @group_line.nil?
	      redirect_to root_url 
	  	end	
    end

    def correct_user_to_delete_group
    	 @group = current_user.groups.find_by(id: params[:id])

    	 if @group.nil?
	      redirect_to root_url 
	  	end	
    end

    def is_correct_user_associated_with_group_line?(group_line)
    	correct_user = false
		
		if signed_in?
    		@group = current_user.groups.find_by(id: group_line.group_id)

    		if group_line.user_id == current_user.id
    			correct_user = true
    		end

    	end

    	if correct_user || !@group.nil? 
    		return true
    	end

    	return false
    end
end
