class GameLinesController < ApplicationController
	include GamesHelper
	before_action :signed_in_business_or_user?, only: [:create, :update, :destroy]

	def create
		# todo- sanitize inputs
		user = User.friendly.find(game_line_params[:user_id])
	  	@game_line = GameLine.new(game_line_params)
	  	
	  	if !user.nil?
			@game_line[:user_id] = user.id
		end

	  	if @game_line.save
	      flash[:success] = "Player added"
	      redirect_to players_path(@game_line.game_id)
	      if @game_line.user != current_business_or_user
	      		Notification.create(recipientable: @game_line.user, actorable: current_business_or_user, 
	      				action: "Invited You", notifiable: @game_line.game)
	      end
	      # if @game_line.accepted == "Accepted" && !@game_line.game.business.nil?
	      # 	Notification.create(recipientable: @game_line.game.business, actorable: current_user, 
	      # 				action: "Confirmed You", notifiable: @game_line.game)
	      # end
	      if @game_line.user == current_user
	      	@game_line.update(accepted: "Requested")
	      	@game_line.save
	      end
	    else
	    	flash[:danger] = "Unable to add player"
	    	redirect_to :back
	    end
	end


	def update
  		@game_line = GameLine.find_by(id: params[:id])

  		flash_msg = choose_flash_message(params[:accepted], @game_line)
  		
		@game_line.update(accepted: params[:accepted])
  		
		if @game_line.save
			flash[:success] = flash_msg
			redirect_to :back
			if @game_line.user != current_business_or_user
				Notification.create(recipientable: @game_line.user, actorable: current_business_or_user, 
	      				action: get_update_notification_message(params[:accepted], @game_line), notifiable: @game_line.game)
			end
			if !@game_line.game.business.nil?
				Notification.create(recipientable: @game_line.game.business, actorable: current_user, 
	      				action: get_update_notification_message(params[:accepted], @game_line), notifiable: @game_line.game)
			end
		else
			flash[:danger] = "Error, please try refresh and try again"
			redirect_to :back
		end	  			
  	end

  	def destroy
	  	@game_line = GameLine.find(params[:id])

	  	if is_correct_user_or_business_associated_with_game_line?(@game_line)
		  	@game_line.destroy
		  	flash[:success] = @game_line.user.first_name + " was deleted"
		  	if @game_line.user != current_business_or_user
		  		Notification.create(recipientable: @game_line.user, actorable: current_business_or_user, 
	      				action: "Removed You", notifiable: @game_line.game)
		  	end
		end
		redirect_to :back
  	end


	private

	def choose_flash_message(accepted_value, gl)
		user_pronoun = ""
		if gl.user == current_user
			user_pronoun = "You are "
		else	
			user_pronoun = gl.user.first_name + " is "
		end

		return user_pronoun + accepted_value.downcase
	end

	def get_update_notification_message(accepted_value, gl)

		if accepted_value == "Accepted"  
			if !gl.game.business.nil?
				return "Confirmed"
			end
			return "Confirmed you"
		else
			if !gl.game.business.nil?
				return "Declined"
			end
			return "Declined you"
		end
	end

	def game_line_params
  		params.require(:game_line).permit(:user_id, :game_id, :accepted, :invited_by)
	end
	
end



			