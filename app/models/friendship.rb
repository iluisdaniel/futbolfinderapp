class Friendship < ActiveRecord::Base
	belongs_to :user
    belongs_to :friend, class_name: "User"

    validate :check_if_user_not_equal_to_friend
	validate :check_if_they_are_already_friends, :on => :create
	# validate :check_if_there_are_any_request_already

    def check_if_user_not_equal_to_friend
      errors.add(:user_id, " error") unless is_user_equal_to_friend?
    end

    def check_if_they_are_already_friends
    	errors.add(:user_id, " error") unless are_friends_already?
    end
    
  	private

	def is_user_equal_to_friend?
		f = Friendship.new(user_id: user_id, friend_id: friend_id, accepted: false)

		if f.user_id == f.friend_id
		  return false
		end

		return true
	end

	def are_friends_already?
		f1 = Friendship.where(user_id: user_id, friend_id: friend_id)
		f2 = Friendship.where(user_id: friend_id, friend_id: user_id)

		if f1.present? || f2.present?
			return false
		end

		return true
	end

end
