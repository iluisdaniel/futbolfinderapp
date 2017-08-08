class GroupsController < ApplicationController
	before_action :signed_in_user, only: [:index, :show, :new, :create]

	def index
		@groups = Group.all
	end

	def show
		@group = Group.find(params[:id])
	end

	def new
		@group = Group.new
	end

	def create
		@group = Group.new(group_params)
		@group[:user_id] = current_user.id

	    if @group.save
	      flash[:success] = "Welcome to futbol finder app"
	    	redirect_to @group
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
