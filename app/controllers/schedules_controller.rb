class SchedulesController < ApplicationController
	before_action :signed_in_business, only: [:create, :destroy]

	def create
		@schedule = current_business.schedules.build(schedule_params)
		if @schedule.save 
			flash[:success] = "Schedule created!"
			redirect_to edit_business_path(current_business.id) 
		else 
			render 'static_pages/home'
		end
	end

	def destroy
	end

	def schedule_params
      params.require(:schedule).permit(:day, :open_time, :close_time, :business)
    end

end