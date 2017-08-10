class Groups::CommentsController < CommentsController
    before_action :set_commentable

    private 
        def set_commentable
            @commentable = Group.find(params[:group_id])
        end
end