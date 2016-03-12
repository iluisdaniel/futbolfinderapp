require 'test_helper'

class BusinessesEditTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

   def setup
    @business = businesses(:canchita)
  end

  test "unsuccessful edit" do
  	log_in_as(@business)
    get edit_business_path(@business)
    assert_template 'businesses/edit'
    patch business_path(@business), business: { name:  "",
                                    email: "foo@invalid",
                                    password:              "foo",
                                    password_confirmation: "bar" }
    assert_template 'businesses/edit'
  end

  test "successful edit with friendly forwarding" do
    get edit_business_path(@business)
    log_in_as(@business)
    assert_redirected_to edit_business_path(@business)
    name  = "Foo Bar"
    email = "foo@bar.com"
    phone = "7862707628"
    city = "Doral"
    state = "Florida"
    zipcode = "33178"
    patch business_path(@business), business: { name:  name,
                                    email: email,
                                    phone: phone,
                                    city: city,
                                    state: state,
                                    zipcode: zipcode,
                                    password:              "",
                                    password_confirmation: "" }
    assert_not flash.empty?
    assert_redirected_to @business
    @business.reload
    assert_equal name,  @business.name
    assert_equal email, @business.email
  end
end
