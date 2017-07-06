require 'test_helper'

class GameTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
  	@user = users(:luis)
  	@business = businesses(:canchita)
  	@field = fields(:one)
  	#@game = games(:one)
    #@schedule = schedules(:one)
    @schedule = Schedule.new(day: "Monday", open_time: "10:00:00", close_time: "22:00:00", business_id: @business.id)
  	
    @game = Game.new(date: "2017-12-11", time: "13:30:05", user_id: 1, 
  		business_id: 1, field_id: 1, end_time: "14:30:05")
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

  
  #### test date and time 

  test "Game Date should be today or later" do 
    @game.date = Date.yesterday
    assert_not @game.valid?
  end

  test "Game should be at least one hour" do 
    @game.time = Time.now
    @game.end_time = Time.now + 50*60
    assert_not @game.valid?
  end

  test "Time should be greater than time now if date is equal today" do
    @game.date = Date.today
    @game.time = Time.now - 5 * 60
    assert_not @game.valid? 
  end

  test "End time should be greater than time" do 
    @game.time = Time.now
    @game.end_time = Time.now - 1 * 60
    assert_not @game.valid?
  end

  ### Test if it is open
  test "Business should have a day in their schedule" do
    day = @game.date.strftime("%A")
    assert_equal(@schedule.day, day, "They should be the same")
  end

  test "Business should have a day in their schedule, negative test" do
    @schedule.day = "Saturday"
    day = @game.date.strftime("%A")
    assert_not_equal(@schedule.day, day, "They should be the same")
  end

end
