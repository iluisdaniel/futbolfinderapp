class GameLinesController < ApplicationController
	include GamesHelper
	before_action :signed_in_business_or_user?, only: [:create, :update, :destroy]


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
	      if @game_line.user != current_business_or_user
	      		Notification.create(recipientable: @game_line.user, actorable: current_business_or_user, 
	      				action: "Invited You", notifiable: @game_line.game)
	      end
	      if @game_line.accepted == true && !@game_line.game.business.nil?
	      	Notification.create(recipientable: @game_line.game.business, actorable: current_user, 
	      				action: "Confirmed", notifiable: @game_line.game)
	      end
	    else
	    	flash[:danger] = "Unable to add player"
	    	redirect_to :back
	    end
	end

	def update
  		@game_line = GameLine.find_by(id: params[:id])
  		
  		@game_line.update(accepted: true)
  		
		if @game_line.save
			flash[:success] = "You are ready to play!"
			redirect_to :back
			if @game_line.user != current_business_or_user
				Notification.create(recipientable: @game_line.user, actorable: current_business_or_user, 
	      				action: "Confirmed You", notifiable: @game_line.game)
			end
			if !@game_line.game.business.nil?
				Notification.create(recipientable: @game_line.game.business, actorable: current_user, 
	      				action: "Confirmed", notifiable: @game_line.game)
			end
		else
			flash[:danger] = "Error, you cannot accept to play"
			redirect_to :back
		end	  			
  	end

  	def destroy
	  	@game_line = GameLine.find(params[:id])

	  	if is_correct_user_or_business_associated_with_game_line?(@game_line)
		  	@game_line.destroy
		  	flash[:success] = "Player was deleted"
		  	if @game_line.user != current_business_or_user
		  		Notification.create(recipientable: @game_line.user, actorable: current_business_or_user, 
	      				action: "Removed You", notifiable: @game_line.game)
		  	end
		end
		redirect_to :back
  	end


	private 

	def game_line_params
  		params.require(:game_line).permit(:user_id, :game_id, :accepted)
	end
	
end



			