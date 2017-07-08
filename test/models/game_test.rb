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
  	
    @game = Game.new(date: "2017-12-18", time: "13:30:05", user_id: 1, 
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

  test "User cannot reserved a 2 games at the same date" do
    @game2 = Game.new(date: "2017-12-11", time: "13:30:05", user_id: 1, 
      business_id: 1, field_id: 1, end_time: "14:30:05")

    assert_not @game2.valid?
  end

  ### Test if it is open
test "Check if the business is open that day" do 
    @schedule.day = "Saturday"
    day = @game.date.strftime("%A")
    assert_not_equal(@schedule.day, day, "They should be the same")
  end

test "check if the business is open at that time" do
  @game.time = "08:00:00"
  assert_not @game.valid?
end  

  test "Business should have a day in their schedule" do
    day = @game.date.strftime("%A")
    assert_equal(@schedule.day, day, "They should be the same")
  end

  ### check fields

  test "business should have at least a field" do 
    @field = nil
    @fields = Field.where(business_id: @business.id)
    assert_not_equal(@fields, 0, "A business should have at least one field")
  end

  
  ## Game Reservation
  test "Game should be reserved only if there are fields available at that time and date" do
    @game2 = Game.new(date: "2017-12-11", time: "13:30:05", user_id: 2, 
      business_id: 1, field_id: 1, end_time: "14:30:05")
    @games = Game.where(date: "2017-12-11", time: "13:30:05")
    @fields = Field.where(business_id: @business.id)
    
    assert_not @fields.count <= @games.count
  end

  test "Game should be reserved if there are enough fields available" do 
    @games = Game.where(date: "2017-12-11", time: "13:30:05")
    @fields = Field.where(business_id: @business.id)

     assert @fields.count >= @games.count
  end

end
