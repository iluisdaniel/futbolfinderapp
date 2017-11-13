class Users::RequestsController < ApplicationController
	before_action :signed_in?, only: :index
	before_action :correct_user, only: :index
	
	def index
		@user = current_user
		@requests = Friendship.where(friend_id: current_user.id, accepted: false)
	end

	private

	def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end

end