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
end
