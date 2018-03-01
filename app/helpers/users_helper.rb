module UsersHelper
	def get_friends_page_subtitle
		if current_page?( controller: '/users/friends', action: 'index')
			return 'Friends'
		elsif current_page?( controller: '/users/pending_friends', action: 'index')
			return 'Pending'
		end
	end

	def get_number_of_requests
		r = Friendship.where(friend_id: current_user.id, accepted: false)
		if !r.empty?
			return r.count
		end
		return nil
	end

	def current_page_user_sign_up?
	  if current_page?(controller: '/users', action: 'new')
	    return true
	  end
	  return false
	end
end
