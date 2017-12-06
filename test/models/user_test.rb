require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
  	@user = users(:jose)
  end

  ###### Valid #################
  test "should be valid" do 
  	assert @user.valid?
  end

######## Precense #####################

  test "first name should be present" do 
    @user.first_name = ""
    assert_not @user.valid?
  end

  test "last name should be present" do 
    @user.last_name = ""
    assert_not @user.valid?
  end

  test "email should be present" do
  	@user.email = ""
  	assert_not @user.valid?
  end

  test "phone should be present" do 
    @user.phone = ""
    assert_not @user.valid?
  end

  test "gender should be present" do 
    @user.gender = ""
    assert_not @user.valid?
  end

  test "Date of Birth should be present" do 
    @user.dob = nil
    assert_not @user.valid?
  end

  ######### Length #######################

   test "first name should not be too long" do
    @user.first_name = "a" * 26
    assert_not @user.valid?
  end

   test "last name should not be too long" do
    @user.last_name = "a" * 26
    assert_not @user.valid?
  end

   test "location should not be too long" do
    @user.location = "a" * 31
    assert_not @user.valid?
  end

   test "gender should not be too long" do
    @user.gender = "aa"
    assert_not @user.valid?
  end

   test "phone should not be too long" do
    @user.phone = "2" * 11
    assert_not @user.valid?
  end

  test "phone should not be too short" do
    @user.phone = "2" 
    assert_not @user.valid?
  end

  test "email should not be too long" do
  	@user.email = "a" * 244 + "@example.com"
  	assert_not @user.valid?
  end

  ################ Uniqness ##########################
   test "email address should be unique" do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  test "phone number should be unique" do
    duplicate_user = @user.dup
    @user.save
    assert_not duplicate_user.valid?
  end

  test "slug should be unique" do
    duplicate_user = @user.dup
    @user.save
    assert_not duplicate_user.valid?
  end

  ############# Specific Fields validation ###############

  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.luis@example.
                           foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test "phone validation should reject invalid phone numbers" do
    invalid_phones = %w[1234567q89a aaaaaaaaaa #qwe123456 !123456789]
    invalid_phones.each do |ps|
      @user.phone = ps
      assert_not @user.valid?, "#{invalid_phones.inspect} should be invalid"
    end

  end

  # test "First name validatioion should reject invalid names" do 
  #   invalid_names = %w[#qwe123456]
  #   invalid_names.each do |n|
  #     @user.first_name = n
  #     assert_not @user.valid?, "#{invalid_names.inspect} should be invalid"
  #   end
  # end


 ################ DOB ############################

end
