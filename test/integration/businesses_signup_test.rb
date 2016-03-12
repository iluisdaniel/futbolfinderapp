require 'test_helper'

class BusinessesSignupTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  test "invalid signup business information" do 
  	get signup_path
  	assert_no_difference 'Business.count' do
  		post businesses_path, business: {name: "", email: "", phone: "", address: "",
  										city: "", state: "", zipcode: "", passwprd: "1234",
  										password_confirmation: "12345"}
  	end
  	assert_template 'businesses/new'
  end

  test "valid signup business information" do
    get signup_path
    assert_difference 'Business.count', 1 do
      post_via_redirect businesses_path, business: { name:  "Example User",
                                            email: "user@example.com",
                                            phone: "7867862323",
                                            address: "8389 NW 115 ct",
                                            city: "Doral",
                                            state: "FLorida",
                                            zipcode: "33178",
                                            password:              "password",
                                            password_confirmation: "password" }
    end
    assert_template 'businesses/show'
    assert is_logged_in?
  end
end
