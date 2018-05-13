class ChargesController < ApplicationController
	before_action :signed_in_business_or_user?
	# before_action :set_charge, only: :show
	before_action :correct_biz_or_user, only: :show

	def index
		if params[:charge_id]
			if Charge.exists?(id: params[:charge_id])
				redirect_to charge_path(params[:charge_id])
			else
				redirect_to charges_path
				flash[:danger] = "Doesn't exist."
			end
		end

		if signed_in?
			if (params[:date] && !params[:date].empty?) || 
				(params[:game] && !params[:game].empty?) || 
				(params[:business] && !params[:business].empty?)
				# @charges = current_user.charges.paginate(page: params[:page], per_page: 15)
				@charges = Charge.findCharges(params[:date], params[:game], params[:business], current_user, params[:page])
			else
				@charges = current_user.charges.order(created_at: :desc).paginate(page: params[:page], per_page: 15)
			end
		else
			if (params[:date] && !params[:date].empty?) || 
				(params[:reservation] && !params[:reservation].empty?) || 
				(params[:username] && !params[:username].empty?)
				# @charges = current_business.charges.paginate(page: params[:page], per_page: 15)
				@charges = Charge.findCharges(params[:date], params[:reservation], params[:username], current_business, params[:page])
			else
				@charges = current_business.charges.order(created_at: :desc).paginate(page: params[:page], per_page: 15)
			end
		end
	end

	def show
		@charge = Charge.find(params[:id])

	  respond_to do |format|
	    format.html
	    format.pdf {
	      send_data(@charge.receipt.render,
	                filename: "#{@charge.id}-store-receipt.pdf",
	                type: "application/pdf",
	                disposition: :inline
	               )
	    }
	  end
	end

	def refund
		begin
			charge = Charge.find(params[:charge_id])

			refund = Stripe::Refund.create({
			  :charge => charge.stripe_id,
			  :refund_application_fee => false,
			}, :stripe_account => current_business.stripe_user_id)

			charge.update(status: "Refunded")

			flash[:success] = "Charge for " + charge.user.first_name + " was refunded succesfully!"
			redirect_to charge.reservation

			Notification.create(recipientable: charge.user, actorable: current_business_or_user, 
			        action: "Refunded your payment for ", notifiable: charge.reservation.game)

		rescue Stripe::InvalidRequestError => e
			flash[:danger] = e.to_s
			redirect_to charge.reservation
		end
	end
	

	private

		def correct_biz_or_user
			begin
				if signed_in?
					charge = current_user.charges.find(params[:id])
					redirect_to charges_path if charge.nil?
				elsif logged_in?
			  		charge = current_business.charges.find(params[:id])
			  		redirect_to charges_path if charge.nil?
			  	end
		  	rescue ActiveRecord::RecordNotFound
	  			redirect_to charges_path
	  			flash[:danger] = "Doesn't exist"
			end
		end

	  def set_charge
	  	if signed_in?
	  		@charge = current_user.charges.find(params[:id])
	  	elsif logged_in?
	    	@charge = current_business.charges.find(params[:id])
	    end
	  end
end