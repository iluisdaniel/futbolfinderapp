require 'test_helper'

class GameTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
  	@user = users(:luis)
  	@business = businesses(:canchita)
  	@field = fields(:one)
    @field2 = fields(:two)
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

  
  #### test date

  test "Game Date should be today or later" do 
    @game.date = 2.day.ago
    assert_not @game.valid?
  end

  test "Game Date should't be greater than one year from now" do
    @game.date = Date.current + 365
    assert_not @game.valid?
  end

### Test Time
  test "Game should be at least one hour" do 
    @game.time = Time.current
    @game.end_time = Time.current + 50*60
    assert_not @game.valid?
  end

  test "Time should be greater than time now if date is equal today" do
    @game.date = Date.today
    @game.time = Time.now - 10 * 60
    @game.end_time = Time.now + 1 * 60 * 60
    assert_not @game.valid? 
  end

  test "End time should be greater than time" do 
    now = Time.now
    @game.time = now
    @game.end_time = now - 10 * 60 * 60
    assert_not @game.valid?
  end

  #### Test Business Schedule
  # check in console --sandbox if you can make a game in a date where there is not day schdule
  # @g = Game.new(date: "2017-07-21", time: "13:30:05", user_id: 1, business_id: 1, field_id: 1, end_time: "14:30:05")
  # @g.valid?
  # @g.errors.full_messages

  #   ## Test if it is open
# test "Check if the business is open that day" do 
#     @schedule.day = "Saturday"
#     day = @game.date.strftime("%A")
#     # assert_not_equal(@schedule.day, day, "They should be the same")
#     assert_not @game.valid?
#   end

# test "check if the business is open at that time" do
#   @game.time = "08:00:00"
#   assert_not @game.valid?
# end  


#   ### check fields

#   test "business should have at least a field" do 
#     @field = nil
#     @fields = Field.where(business_id: @business.id)
#     assert_not_equal(@fields, 0, "A business should have at least one field")
#   end

#   test "this field doesn't belong to the business" do
#     @game2 = Game.new(date: "2017-12-18", time: "13:30:05", user_id: 1, 
#       business_id: 1, field_id: 2, end_time: "14:30:05")

#     assert @game.valid?
#   end

  
#   ## Game Reservation

#   # test "User cannot reserved a 2 games at the same date" do
#   #   @game2 = Game.new(date: "2017-12-11", time: "13:30:05", user_id: 1, 
#   #     business_id: 1, field_id: 1, end_time: "14:30:05")

#   #   assert_not @game2.valid?
#   # end

#   test "Game should be reserved only if there are fields available at that time and date" do
#     @game2 = Game.new(date: "2017-12-11", time: "13:30:05", user_id: 2, 
#       business_id: 1, field_id: 1, end_time: "14:30:05")
#     @games = Game.where(date: "2017-12-11", time: "13:30:05")
#     @fields = Field.where(business_id: @business.id)
    
#     assert_not @fields.count <= @games.count
#   end

#   test "Game should be reserved if there are enough fields available" do 
#     @games = Game.where(date: "2017-12-11", time: "13:30:05")
#     @fields = Field.where(business_id: @business.id)

#      assert @fields.count >= @games.count
#   end

  # test "Game for other player in the same field and same time is not valid" do
  #   @game2 = Game.new(date: "2017-12-18", time: "13:30:05", user_id: 2, 
  #     business_id: 1, field_id: 1, end_time: "14:30:05")

  #   assert_not @game2.valid?
  # end

end
