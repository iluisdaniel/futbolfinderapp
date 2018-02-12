class GameLine < ApplicationRecord
  belongs_to :game
  belongs_to :user 

  before_save :set_defaults, if: :new_record?

  validate :validate_user_exists
  validate :validate_user_is_not_duplicate
  validate :check_users_are_friends_at_invitation, on: :create
  # validate :validate_user_is_not_game_creator

  	# TODO -  Fix how to handle exception out of range for ActiveRecord::Type::Integer when you input a lonng integer in the invite players

    def set_defaults
        self.accepted = "Pending"
    end

    def validate_user_exists
  		errors.add(:user_id, "User doesn't exist") unless does_user_exist?
  	end

  	def validate_user_is_not_duplicate
  		errors.add(:user_id, "User is already there") unless can_the_user_be_added?
  	end

    def check_users_are_friends_at_invitation
      errors.add(:user_id, "Users are not friends") unless are_users_friends?
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

    def are_users_friends?
      user = User.friendly.find(user_id)
      

      if invited_by.nil?
        return true
      else
        user2 = User.find(invited_by) 
      end

      if user2.is_a_friend?(user)
        return true
      end
      return false
    end


  	# def is_the_user_the_game_creator?
  	# 	game = Game.find_by(id: game_id)

  	# 	if  game.user_id == user_id
  	# 		return false
  	# 	end
  	# 	return true
  	# end
end
