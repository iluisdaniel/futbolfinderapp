class SchedulesController < ApplicationController
	before_action :signed_in_business, only: [:create, :destroy, :edit, :update]
	before_action :correct_business,   only: [:destroy, :edit, :update]

	def create
		@schedule = current_business.schedules.build(schedule_params)
		if @schedule.save 
			flash[:success] = "Schedule created!"
			redirect_to edit_business_path(current_business.id) 
		else 
			flash[:danger] = "Error, Schedule was not created. " + @schedule.errors.full_messages.to_s
			redirect_to edit_business_path(current_business.id) 
		end
	end

	def edit
		@schedule = Schedule.find(params[:id])
	end

	def update
		@schedule = Schedule.find(params[:id])

		if @schedule.update_attributes(schedule_params)
			flash[:success] = "Schedule updated"
			redirect_to edit_business_path(@schedule.business)
		else
			render 'edit'
		end
	end

	def destroy
		@schedule.destroy
		flash[:success] = "Schedule destroyed"
		redirect_to edit_business_path(current_business.id)
	end

	private

		def schedule_params
    	  	params.require(:schedule).permit(:day, :open_time, :close_time, :business)
   		end

   		def correct_business
	      @schedule = current_business.schedules.find_by(id: params[:id])
	      redirect_to root_url if @schedule.nil?
    	end

end