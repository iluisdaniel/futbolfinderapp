require 'test_helper'

class BusinessTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  def setup
  	@business = Business.new(name: "La Caimanera", email: "caimanera@example.com", phone: "7862367863", address: "8323 nw 12 ct", city: "Doral", 
  		state: "Florida", zipcode: "33189", password: "123456", password_confirmation: "123456")
  end

  test "should be valid" do
  	assert @business.valid?
  end

  test "name should be present" do 
  	@business.name = "    "
  	assert_not @business.valid?
  end

  test "email should be present" do 
  	@business.email = "    "
  	assert_not @business.valid?
  end

  test "phone should be present" do 
  	@business.phone = "    "
  	assert_not @business.valid?
  end

  test "adress should be present" do 
  	@business.address = "    "
  	assert_not @business.valid?
  end

  test "city should be present" do 
  	@business.city = "    "
  	assert_not @business.valid?
  end

  test "state should be present" do 
  	@business.state = "    "
  	assert_not @business.valid?
  end

   test "zipcode should be present" do 
  	@business.zipcode = "    "
  	assert_not @business.valid?
  end

  test "name should not be too long" do
  	@business.name = "a" * 51
  	assert_not @business.valid?
  end

  test "email should not be too long" do
  	@business.email = "a" * 244 + "@example.com"
  	assert_not @business.valid?
  end

  test "phone should not be too long" do
  	@business.phone = "30578623232"
  	assert_not @business.valid?
  end

  test "address should not be too long" do
  	@business.address = "a" * 260
  	assert_not @business.valid?
  end

  test "city should not be too long" do
  	@business.city = "a" * 51
  	assert_not @business.valid?
  end

  test "state should not be too long" do
  	@business.state = "a" * 51
  	assert_not @business.valid?
  end

  test "zipcode should not be too long" do
  	@business.zipcode = "a" * 6
  	assert_not @business.valid?
  end

  test "zipcode should not be too small" do
  	@business.zipcode = "a" * 4
  	assert_not @business.valid?
  end

  test "phone should not be too small" do
  	@business.phone = "789789789"
  	assert_not @business.valid?
  end

  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @business.email = invalid_address
      assert_not @business.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test "email address should be unique" do
  	duplicate_business = @business.dup
  	duplicate_business.email = @business.email.upcase
  	@business.save
  	assert_not duplicate_business.valid?
  end

  test "password should be present (nonblank)" do
    @business.password = @business.password_confirmation = " " * 6
    assert_not @business.valid?
  end

  test "password should have a minimum length" do
    @business.password = @business.password_confirmation = "a" * 5
    assert_not @business.valid?
  end


end
