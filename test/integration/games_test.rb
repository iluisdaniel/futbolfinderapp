require 'test_helper'

class GamesTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  def setup
  	@business = businesses(:canchita)
    @user = users(:jose)
  end

  # test "Create a game" do
  #   # get login_path
  #   # post login_path, session: { email: @business.email, password: 'password' }
  #   # assert_redirected_to @business
  #   get login_path
  #   post login_path, params: { session: {email: @user.email, password: 'password' } } 
  #   assert_response :redirect
  #   follow_redirect!
  #   assert_response :success
  #   # assert flash.empty?
  #   # assert_redirected_to @user
  #   # follow_redirect
  #   post games_path, params: { game: { title: "This is a test", description: "hello, this is a description",
  #   	number_players: 10, public: "Public", invite_allowed: true }}
  #   assert_redirected_to available_fields_path(game: game)
  #   follow_redirect!
  #   assert_response :success



  # end
  
end
