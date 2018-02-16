class SubscriptionsController < ApplicationController
	
	def new
	end

	def create
		customer = current_business.stripe_customer

		begin
			subscription = customer.subscriptions.create(
				source: params[:stripeToken],
				plan: params[:plan]
			)

			current_business.assign_attributes(stripe_subscription_id: subscription.id, expires_at: nil)
			current_business.assign_attributes(
				card_brand: params[:card_brand],
				card_last4: params[:card_last4],
				card_exp_month: params[:card_exp_month],
				card_exp_year: params[:card_exp_year]
			) if params[:card_last4]

			current_business.save

			flash[:success] = "Thanks for subscribing!"
			redirect_to root_path	
		rescue	Stripe::CardError => e
			flash[:danger] = e.message
			render 'new'
		end
	end

	def show
	end

	def update
		customer = current_business.stripe_customer

		begin
			source = customer.sources.create(source: params[:stripeToken])

			customer.default_source = source.id
			customer.save

			current_business.assign_attributes(
				card_brand: params[:card_brand],
				card_last4: params[:card_last4],
				card_exp_month: params[:card_exp_month],
				card_exp_year: params[:card_exp_year]
			)

			current_business.save

			flash[:success] = "Card Updated!"
			redirect_to root_path
		rescue Stripe::CardError => e
			flash[:danger] = e.message
			render 'show'
		end

	end

	def destroy
		customer = current_business.stripe_customer
		subscription = customer.subscriptions.retrieve(current_business.stripe_subscription_id).delete

		expires_at = Time.zone.at(subscription.current_period_end)

		current_business.update(expires_at: expires_at, stripe_subscription_id: nil)

		flash[:warning] = "You have canceled your subscription. You will have access until #{current_business.expires_at.to_date}"
		redirect_to root_path

	end
end