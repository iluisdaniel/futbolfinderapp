require 'test_helper'

class SessionsHelperTest < ActionView::TestCase

  def setup
    @business = businesses(:canchita)
    remember(@business)
  end

  test "current_business returns right business when session is nil" do
    assert_equal @business, current_business
    assert is_logged_in?
  end

  test "current_business returns nil when remember digest is wrong" do
    @business.update_attribute(:remember_digest, Business.digest(Business.new_token))
    assert_nil current_business
  end
end