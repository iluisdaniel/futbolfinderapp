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

end
