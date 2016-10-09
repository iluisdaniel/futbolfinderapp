class FieldsController < ApplicationController
  before_action :signed_in_business, only: [:create, :update, :destroy]
  before_action :correct_business,   only: :destroy

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
  	@field.destroy
  	redirect_to edit_business_path(current_business.id)
  end

  def update
  end

  private 

  		def field_params
    	  	params.require(:field).permit(:number_players, :name, :description, :price)
   		end

   		def correct_business
	      @field = current_business.fields.find_by(id: params[:id])
	      redirect_to root_url if @field.nil?
    	end
	
end