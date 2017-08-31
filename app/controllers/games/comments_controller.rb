class Games::CommentsController < CommentsController
    before_action :set_commentable
    
    private 
        def set_commentable
            @commentable = Game.find(params[:game_id])
        end
end