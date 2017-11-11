class NotificationsController < ApplicationController
	include NotificationsHelper
	after_action :mark_as_read, only: [:index]
	
	def index
			@notifications = Notification.where(recipientable: current_business_or_user).order(created_at: :desc)
	end

	private

	def mark_as_read
		@notifications = Notification.where(recipientable: current_business_or_user).unread
		@notifications.update_all(read_at: Time.zone.now)
	end

end