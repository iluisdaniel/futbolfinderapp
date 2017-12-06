class Users::FriendsController < ApplicationController
	before_action :signed_in?, only: :index
	
	def index
		@user = User.friendly.find(params[:id])
		@friends = @user.friends
	end

end