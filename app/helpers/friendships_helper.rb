module FriendshipsHelper
	# returns false if they are not friends
	def are_they_friends?(user)
		f1 = Friendship.where(user_id: user.id, friend_id: current_user.id, accepted: true)
		f2 = Friendship.where(user_id: current_user.id, friend_id: user.id, accepted: true)

		if f1.empty? && f2.empty?
			return false
		end

		return true
	end

	def is_the_friendship_pending?(user)
		current_user.pending.each do |u|
			if u == user
				return true
			end
		end
		return false
	end

	def is_the_friendship_requested?(user)

		current_user.requested_friendships.each do |u|
			if user == u
				return true
			end
		end
		return false
	end

	def get_friendship_requested_id(user)
		fs = Friendship.where(user_id: user.id, friend_id: current_user, accepted: false)
		if !fs.empty?
			return fs.first.id
		end
	end
end

