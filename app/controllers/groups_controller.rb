class GroupsController < ApplicationController
	include GroupsHelper
	before_action :signed_in_user, only: [:index, :show, :new, :create]
	before_action :correct_user_to_see_group,   only: [:show]

	def index
		@groups = Group.all
	end

	def show
		@group = Group.find(params[:id])
		@group_lines = @group.group_lines
		@group_line = GroupLine.new
	end

	def new
		@group = Group.new
	end

	def create
		@group = Group.new(group_params)
		@group[:user_id] = current_user.id

	    if @group.save
	    	redirect_to @group
	    	flash[:success] = "Welcome to futbol finder app"
	    	GroupLine.create(user_id: @group.user_id, group_id: @group.id)
	    else
	      render 'new'
	    end
	end

  private

    def group_params
      params.require(:group).permit(:title, :about)
    end

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end


end
