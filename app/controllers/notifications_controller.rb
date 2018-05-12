class NotificationsController < ApplicationController
	include NotificationsHelper
	after_action :mark_as_read, only: [:index]
	
	#### TODO fix notifications
	#### TODO Add notification when users that add themselves into a game, for admins to know
	#### TODO Add notifications when players accept and cancel invitations
	#### TODO When decline game, make it apper in a view
	def index
			@notifications = Notification.where(recipientable: current_business_or_user).order(created_at: :desc)
										.paginate(page: params[:page], per_page: 15)
	end

	private

	def mark_as_read
		@notifications = Notification.where(recipientable: current_business_or_user).unread
		@notifications.update_all(read_at: Time.zone.now)
	end

end