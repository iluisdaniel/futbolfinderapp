class CustomVenuesController < ApplicationController
	before_action :signed_in_user_but_not_business?, only: :create
	before_action :correct_user, only: :destroy

	def create
		@custom_venue = CustomVenue.new(custom_venue_params)
		if @custom_venue.save
			flash[:success] = "Venue and time created"
			redirect_to @custom_venue.game
		else

			flash[:danger] = "Error, Venue and Time was not created. Please, try again."
			redirect_to root_path
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
