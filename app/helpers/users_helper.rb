module UsersHelper
	def is_at_user_page?
        if current_page?(controller: 'users', action: 'show') 

            return true
        end

        return false
    end
end
