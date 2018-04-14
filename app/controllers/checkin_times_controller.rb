class CheckinTimesController < ApplicationController
  before_action :signed_in_business, only: [:create, :destroy]
  # before_action :correct_business,   only: :destroy

  def create
    @checkin_time = CheckinTime.new(checkin_time_params)
    if @checkin_time.save
      @checkin_time.reservation.charge_players
      flash[:success] = "Checkin succesful"
      redirect_to @checkin_time.reservation
    else
       flash[:success] = "There was a problem, please try again. If problem persist, contac support"
      redirect_to @checkin_time.reservation
    end
  end

  def destroy
  	# @field.destroy
  	# redirect_to edit_business_path(current_business.id)
  end

  private 

  		def checkin_time_params
    	  	params.require(:checkin_time).permit(:reservation_id)
   		end

   		# def correct_business
	    #   @field = current_business.fields.find_by(id: params[:id])
	    #   redirect_to root_url if @field.nil?
    	# end
	
end