require 'test_helper'

class BusinessesControllerTest < ActionController::TestCase
  
	def setup
		@business = businesses(:canchita)
		@other_business = businesses(:caimanera)
	end

  test "should redirect index when not logged in" do
    get :index
    assert_redirected_to login_url
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should redirect edit when not logged in" do
    get :edit, id: @business
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect update when not logged in" do
    patch :update, id: @business, business: { name: @business.name, email: @business.email }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

 test "should redirect edit when logged in as wrong business" do
    log_in_as(@other_business)
    get :edit, id: @business
    assert flash.empty?
    assert_redirected_to root_url
  end

  test "should redirect update when logged in as wrong business" do
    log_in_as(@other_business)
    patch :update, id: @business, business: { name: @business.name, email: @business.email }
    assert flash.empty?
    assert_redirected_to root_url
  end

end
