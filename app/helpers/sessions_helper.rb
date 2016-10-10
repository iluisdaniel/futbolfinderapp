module SessionsHelper

	# Logs in the given business.
	def log_in(business)
		session[:business_id] = business.id
	end

	 # Remembers a business in a persistent session.
  def remember(business)
    business.remember
    cookies.permanent.signed[:business_id] = business.id
    cookies.permanent[:remember_token] = business.remember_token
  end

  # Returns true if the given user is the current user.
  def current_business?(business)
    business == current_business
  end

  def signed_in_business
    unless logged_in?
      store_location
      redirect_to signin_url, notice: "Please sign in"
    end
  end

	 # Returns the current logged-in business (if any).
  def current_business
    if (business_id = session[:business_id])
      @current_business ||= Business.find_by(id: business_id)
    elsif (business_id = cookies.signed[:business_id])
      business = Business.find_by(id: business_id)
      if business && business.authenticated?(cookies[:remember_token])
        log_in business
        @current_business = business
      end
    end
  end

  # Returns true if the business is logged in, false otherwise.
  def logged_in?
    !current_business.nil?
  end

  # Forgets a persistent session.
  def forget(business)
    business.forget
    cookies.delete(:business_id)
    cookies.delete(:remember_token)
  end

  #logs out the current business
  def log_out
  	forget(current_business)
  	session.delete(:business_id)
  	@current_business = nil
  end

  # Redirects to stored location (or to the default).
  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  # Stores the URL trying to be accessed.
  def store_location
    session[:forwarding_url] = request.url if request.get?
  end

  #For Users

  def sign_in(user)
    remember_token = User.new_remember_token
    cookies.permanent[:remember_token] = remember_token
    user.update_attribute(:remember_token, User.digest(remember_token))
    self.current_user = user
  end

  def signed_in?
    !current_user.nil?
  end

  def current_user=(user)
    @current_user = user
  end

  def current_user
    remember_token = User.digest(cookies[:remember_token])
    @current_user ||= User.find_by(remember_token: remember_token)
  end

  def sign_out
    current_user.update_attribute(:remember_token,
                                  User.digest(User.new_remember_token))
    cookies.delete(:remember_token)
    self.current_user = nil
  end
end
