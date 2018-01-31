ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require "minitest/reporters"
Minitest::Reporters.use!

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def is_logged_in?
  	!session[:business_id].nil?
  end

  def get_next_monday_date
    d = Date.today
    if d.strftime("%A") == "Monday"
      d = d + 7.days
    else
      found = false
      while !found do 
        if d.strftime("%A") == "Monday"
          found = true
        else
          d = d + 1.days
        end
      end
    end

    return d
  end

   # Logs in a test user.
  def log_in_as(business, options = {})
    password    = options[:password]    || 'password'
    remember_me = options[:remember_me] || '1'
    if integration_test?
      post login_path, session: { email:       business.email,
                                  password:    password,
                                  remember_me: remember_me }
    else
      session[:business_id] = business.id
    end
  end

  private

    # Returns true inside an integration test.
    def integration_test?
      defined?(post_via_redirect)
    end
end
