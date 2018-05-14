class LaunchingEmailsController < ApplicationController
	
	def create
		@launching_email = LaunchingEmail.new(email: params[:email])

		if @launching_email.save
			redirect_to root_path(email: "Saved", message_type: "success", message: "Email saved!" )
		else
			redirect_to root_path( message_type: "dabger", message: "Sorry email was not saved. Please try again. " + @launching_email.errors.full_messages.to_s)
		end
	end

	private

	def email_params
		params.require(:launching_email).permit(:email)
	end
end
