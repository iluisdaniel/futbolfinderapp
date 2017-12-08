class Users::FriendsController < ApplicationController
	before_action :signed_in?, only: :index
	require 'will_paginate/array'
	
	def index
		@user = User.friendly.find(params[:id])
		@friends = @user.friends.paginate(page: params[:page], per_page: 20)
	end

end