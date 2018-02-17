class ChargesController < ApplicationController
	before_action :signed_in_business
	before_action :set_charge

	def show
	  respond_to do |format|
	    format.pdf {
	      send_data(@charge.receipt.render,
	                filename: "#{@charge.id}-store-receipt.pdf",
	                type: "application/pdf",
	                disposition: :inline
	               )
	    }
	  end
	end

	private

	  def set_charge
	    @charge = current_business.charges.find(params[:id])
	  end
end