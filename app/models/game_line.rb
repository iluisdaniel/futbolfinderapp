class GameLine < ActiveRecord::Base
  belongs_to :game
  belongs_to :user 

  validate :validate_user_exists
  validate :validate_user_is_not_duplicate
  # validate :validate_user_is_not_game_creator

  	def validate_user_exists
  		errors.add(:user_id, "User doesn't exist") unless does_user_exist?
  	end

  	def validate_user_is_not_duplicate
  		errors.add(:user_id, "User is already there") unless can_the_user_be_added?
  	end

  	# def validate_user_is_not_game_creator
  	# 	errors.add(:user_id, "cant add the admin") unless is_the_user_the_game_creator?
  	# end

  	private

  	def does_user_exist?
	    user = User.where(id: user_id)

	    if user.empty?
	      return false
	    end

	    return true
  	end

  	def can_the_user_be_added?
  		game_line = GameLine.where(game_id: game_id, user_id: user_id)

  		if game_line.empty?
  			return true
  		else

        if !accepted.nil?
          return true
        else
          return false
        end
      end

  	end

  	# def is_the_user_the_game_creator?
  	# 	game = Game.find_by(id: game_id)

  	# 	if  game.user_id == user_id
  	# 		return false
  	# 	end
  	# 	return true
  	# end
end
