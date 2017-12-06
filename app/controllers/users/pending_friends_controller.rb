class Users::PendingFriendsController < ApplicationController
	before_action :signed_in?, only: :index
	before_action :correct_user, only: :index
	
	def index
		@user = current_user
		@friends = @user.pending
	end

	private

	def correct_user
      @user = User.friendly.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end

end