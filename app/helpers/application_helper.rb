module ApplicationHelper

	# Returns the full title on a per-page basis.
  def full_title(page_title = '')
    base_title = "Futbol Finder App"
    if page_title.empty?
      base_title
    else
      page_title + " | " + base_title
    end
  end

  def show_title_page_header(title, secondaryTitle)
  	if !title.empty?
  		render partial: "layouts/title_page_header", locals: {title: title, secondaryTitle: secondaryTitle}
  	end
  end

  def get_number_notifications
      return Notification.where(recipientable: current_business_or_user).unread.count
  end

  def is_a_valid_email?(email)
      if (email =~ /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i).nil?
        return false
      end
      return true
  end

  def is_login_or_sign_up_been_shown?
    if current_page?(controller: '/users', action: 'new') || 
      current_page?(controller: '/sessions', action: 'create') ||
      current_page?(controller: '/sessions', action: 'new')
          true
    end
  end

  def is_current_page_business_sign_up?
    if current_page?(controller: '/businesses', action: 'new')
          true
    end
  end

end
