class GameLinesController < ApplicationController
	include GamesHelper
	before_action :signed_in_business_or_user?, only: [:create, :destroy]


	def create
		# todo- sanitize inputs
	  	@game_line = GameLine.new(game_line_params)
	  	user =  find_user_with_email(game_line_params[:user_id])
	  	
	  	if !user.nil?
			@game_line[:user_id] = user.id
		end

	  	if @game_line.save
	      flash[:success] = "Player added"
	      redirect_to game_path(@game_line.game_id)
	    else
	    	flash[:error] = "Unable to add player"
	    	redirect_to :back
	    end
	end

  	def destroy
	  	@game_line = GameLine.find(params[:id])

	  	if is_correct_user_or_business_associated_with_game_line?(@game_line)
		  	@game_line.destroy
		  	flash[:success] = "Player were deleted"
		end
		redirect_to :back
  	end



	private 

	def game_line_params
  		params.require(:game_line).permit(:user_id, :game_id)
	end
	
end



			