require 'test_helper'

class LoginTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  def setup
  	@business = businesses(:canchita)
    @user = users(:jose)
  end


  test "login with invalid information" do
    get login_path
    assert_template 'sessions/new'
    post login_path, params: { session: { email: "", password: "" } }
    assert_template 'sessions/new'
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end

  test "User login with valid information" do
    # get login_path
    # post login_path, session: { email: @business.email, password: 'password' }
    # assert_redirected_to @business
    get login_path
    post login_path, params: { session: {email: @user.email, password: 'password' } } 
    assert_response :redirect
    follow_redirect!
    assert_response :success
    # assert flash.empty?
    # assert_redirected_to @user
    # follow_redirect
    get edit_user_path(@user)
    assert_response :success

  end

  test "User login with valid information followed by logout" do 
    get login_path
    post login_path, params: { session: {email: @user.email, password: 'password' } } 
    assert_response :redirect
    follow_redirect!
    assert_response :success
    get edit_user_path(@user)
    assert_response :success
    delete logout_path
    # assert_response :redirect
    # follow_redirect!
    # assert_response :success
    get edit_user_path(@user)
    assert_response :redirect
    assert_not flash.empty?
  end

  test "Business login with valid information" do 
    get login_path
    post login_path, params: { session: {email: @business.email, password: 'password' } }
    assert_response :redirect
    follow_redirect!
    assert_response :success
    get edit_business_path(@business)
    assert_response :success
  end

  test "Business login with valid information followed by a log out" do
    get login_path
    post login_path, params: { session: {email: @business.email, password: 'password' } }
    assert_response :redirect
    follow_redirect!
    assert_response :success
    get edit_business_path(@business)
    assert_response :success
    delete logout_path
    get edit_business_path(@business)
    assert_response :redirect
    assert_not flash.empty?
  end

  # test "login with valid information followed by logout" do
  #   get login_path
  #   post login_path, session: { email: @business.email, password: 'password' }
  #   assert_redirected_to @business
  #   assert is_logged_in?
  #   assert_redirected_to @business
  #   delete logout_path
  #   assert_not is_logged_in?
  #   assert_redirected_to root_url
  #   #Simulate a business clicking in a second window
  #   delete logout_path
  #   follow_redirect!
  #   assert_select "a[href=?]", login_path
  #   assert_select "a[href=?]", logout_path,      count: 0
  #   assert_select "a[href=?]", business_path(@business), count: 0
  # end

  # test "login with remembering" do
  #   log_in_as(@business, remember_me: '1')
  #   assert_not_nil cookies['remember_token']
  # end

  # test "login without remembering" do
  #   log_in_as(@business, remember_me: '0')
  #   assert_nil cookies['remember_token']
  # end
end
