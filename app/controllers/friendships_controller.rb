class FriendshipsController < ApplicationController
	before_action :signed_in_user, only: [:create, :update, :destroy]

	def create
     @friendship = current_user.friendships.build(friend_id: params[:friend_id])
      if @friendship.save
        flash[:success] = "Friend requested."
        redirect_to :back
        Notification.create(recipientable: @friendship.friend, actorable: current_user, 
            action: "Added You", notifiable: @friendship)
      else
        flash[:error] = "Unable to request friendship."
        redirect_to :back
      end
    end

    def update
     @friendship = Friendship.find_by(id: params[:id])
     @friendship.update(accepted: true)

      if @friendship.save
        redirect_to user_path(@friendship.user_id) 
        flash[:success] = "Successfully confirmed friend!"
        Notification.create(recipientable: @friendship.user, actorable: current_user, 
            action: "Accepted Your", notifiable: @friendship)
      else
        redirect_to root_url, notice: "Sorry! Could not confirm friend!"
      end
    end

    def destroy
      @friendship = Friendship.find_by(id: params[:id])
      @friendship.destroy
      flash[:success] = "Removed friendship."
      redirect_to :back
    end
end