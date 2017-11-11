class CommentsController < ApplicationController
    before_action :signed_in_user

    def create
        @comment = @commentable.comments.new comment_params
        @comment.user_id = current_user.id
        @comment.save
        flash[:success] = "Your comment was successfully posted."
        redirect_to @commentable
        @commentable.game_lines.each do |gl|
            if gl.user != current_user
                Notification.create(recipientable: gl.user, actorable: current_user, 
                        action: "Commented", notifiable: @commentable)
            end
        end
    end

    private

        def comment_params
            params.require(:comment).permit(:body)
        end
end