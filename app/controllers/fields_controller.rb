class FieldsController < ApplicationController
  before_action :signed_in_business, only: [:create, :edit, :update, :destroy]
  before_action :correct_business,   only: [:destroy, :edit, :update]

  def create
  	@field = current_business.fields.build(field_params)
		if @field.save 
			flash[:success] = "Field created!"
			redirect_to edit_business_path(current_business.id) 
		else 
			flash[:danger] = "Error, Field was not created"
			redirect_to edit_business_path(current_business.id)
		end
  end

  def destroy
  	if get_number_of_current_reservations_for_field(@field) == 0
      @field.destroy
    	redirect_to edit_business_path(current_business.id)
    else
      flash[:danger] = "There are " + get_number_of_current_reservations_for_field(@field).to_s + 
                        " current reservations related to this field. Please, resolved them before deleting this field."
      redirect_to edit_business_path(current_business.id)
    end
  end

  def edit
    @field = Field.find(params[:id])
  end

  def update
    @field = Field.find(params[:id])

    if @field.update_attributes(field_params)
      flash[:success] = "Field updated"
      redirect_to edit_business_path(@field.business)
    else
      render 'edit'
    end
  end

  private 

  		def field_params
    	  	params.require(:field).permit(:number_players, :name, :description, :price)
   		end

   		def correct_business
	      @field = current_business.fields.find_by(id: params[:id])
	      redirect_to root_url if @field.nil?
    	end

      def get_number_of_current_reservations_for_field(field)
         n = 0
        res = Reservation.where('field_id = ? AND date >= ? AND time >= ?', field.id, Date.current, Time.zone.now)
        res.each do |r|
          if r.checkin_time
            n = n + 1
          end
        end
        return n
      end
	
end