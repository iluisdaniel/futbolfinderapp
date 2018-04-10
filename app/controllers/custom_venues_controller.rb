class CustomVenuesController < ApplicationController
	before_action :signed_in_user_but_not_business?, only: :create
	before_action :correct_user, only: :destroy

	def new
		@custom_venue = CustomVenue.new
		if params[:game]
			session[:cv_game] = params[:game]
		end
	end

	def create
		@custom_venue = CustomVenue.new(custom_venue_params)
		if @custom_venue.save		
				flash[:success] = "Venue and time created"
				if session[:cv_game]
					@custom_venue.update(game_id: (session[:cv_game].to_s).to_i)
					session[:cv_game] = nil
				end
				redirect_to @custom_venue.game
		else	
			# flash[:danger] = "Error, Venue and Time was not created. Please, try again." + @custom_venue.errors.full_messages.to_s
			render 'new'
		end
	end

	def destroy
		game = @custom_venue.game
		@custom_venue.destroy
		flash[:success] = "Venue destroyed"
		redirect_to game
	end

	private

	def custom_venue_params
		params.require(:custom_venue).permit(:number_players, :ground, :field_type, :address, :city, 
  											:state, :zipcode, :date, :time, :end_time, :game_id)
	end

	def correct_user
		@custom_venue = CustomVenue.find(params[:id])
		if @custom_venue.game.user == current_user
			return true
		end
		return false
	end
		

end
