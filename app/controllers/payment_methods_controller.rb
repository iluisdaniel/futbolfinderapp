class PaymentMethodsController < ApplicationController
	 before_action :signed_in_user, only: [:new, :create]
	
	def new
	end

	def create
		customer = current_user.stripe_customer

		begin
			source = customer.sources.create(source: params[:stripeToken])

			customer.default_source = source.id
			customer.save

			current_user.assign_attributes(
				card_brand: params[:card_brand],
				card_last4: params[:card_last4],
				card_exp_month: params[:card_exp_month],
				card_exp_year: params[:card_exp_year]
			) if params[:card_last4]

			current_user.save

			if params[:date]
				redirect_to confirmation_path(game: params[:game], business: params[:business], field: params[:field],
					date: params[:date], time: params[:time], source: "card")
			else
				flash[:success] = "Card Added!"
				redirect_to root_path
			end

			
		rescue Stripe::CardError => e
			flash[:danger] = e.message
			render 'new'
		end
	end
	
end