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


  def include_menu_bar(include_menu)
    if include_menu.empty?
      if logged_in?
        render 'layouts/header_businesses' 
      elsif signed_in?
        render 'layouts/header'
      else
        render 'layouts/header_no_user'
      end     
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

  def get_stripe_connect_url
    "https://connect.stripe.com/oauth/authorize?response_type=code&client_id=" + 
    Rails.application.secrets.stripe_client_id + "&scope=read_write"
  end

end
