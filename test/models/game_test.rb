require 'test_helper'

class GameTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
  	@user = users(:luis)
  	@business = businesses(:canchita)
  	@field = fields(:one)
  	@game = games(:one)

  	#Game.new(date: "2016-12-12", time: "13:30:05", user_id: @user_id, 
  		#business_id: @business_id, field_id: @field_id)
  end

  test "game should be valid" do
  	assert @game.valid?
  end

  test "user id should be present" do 
  	@game.user_id = nil
    assert_not @game.valid?
  end

  test "business id should be present" do 
  	@game.business_id = nil
  	assert_not @game.valid?
  end

  test "field id should be present" do 
  	@game.field_id  = nil
  	assert_not @game.valid?
  end
end
