require 'test_helper'

class FieldTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
  	@business = businesses(:canchita)
  	@field = fields(:one)
  end

  test "should be valid" do
  	assert @field.valid?
  end

  test "business with field should be valid" do
  	assert @business.valid?
  end

  test "business id should be present" do
  	@field.business_id = nil
  	assert_not @field.valid? 
  end

  test "field name should be present" do
  	@field.name = ""
  	assert_not @field.valid? 
  end

   test "name should not be too long" do
  	@field.name = "a" * 51
  	assert_not @field.valid?
  end

  test "field price should be present" do
  	@field.price = nil
  	assert_not @field.valid? 
  end

  test "field price can't be a letter" do
  	@field.price = "Hola"
  	assert_not @field.valid? 
  end

  test "field price can't be 0" do
  	@field.price = 0
  	assert_not @field.valid? 
  end

  test "field price can't be greater than 10000" do
  	@field.price = 11000
  	assert_not @field.valid? 
  end

end
