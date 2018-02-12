class GroupLinesController < ApplicationController
	include GroupsHelper
	before_action :signed_in?, only: [:create, :destroy]


	def create
	  	@group_line = GroupLine.new(group_line_params)
	  	if @group_line.save
	      flash[:success] = "Player added"
	      redirect_to group_path(@group_line.group_id)
	    else
	    	flash[:error] = "Unable to add player"
	    	redirect_back fallback_location: root_path
	    end
	end

  	def destroy
	  	@group_line = GroupLine.find(params[:id])

	  	if is_correct_user_associated_with_group_line?(@group_line)
		  	@group_line.destroy
		  	flash[:success] = "Player were deleted"
		end
		redirect_back fallback_location: root_path
  	end



	private 

	def group_line_params
  		params.require(:group_line).permit(:group_id, :user_id)
	end
end
