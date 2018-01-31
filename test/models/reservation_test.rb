require 'test_helper'

class ReservationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
  	@business = businesses(:canchita)
  	@field = fields(:one)
  	@schedule = Schedule.new(day: "Monday", open_time: "10:00:00", close_time: "22:00:00", business_id: @business.id)
  	@reservation = Reservation.new(time: "13:00:00", 
  		end_time: "14:00:00", business_id: @business.id, field_id: @field.id)
    @reservation.date = get_next_monday_date
  end

  test "should be valid" do 
  	assert @reservation.valid?
  end

  ############# Presence ####################

  test "field should be present" do
  	@reservation.field_id = nil
  	assert_not @reservation.valid? 
  end

  ####### Check Date #################

  test "date should later than today" do
  	@reservation.date = "2017-12-04"
  	assert_not @reservation.valid? 
  end

  test "date should later than one year" do
  	@reservation.date = @reservation.date + 1.year
  	assert_not @reservation.valid? 
  end

  ############ Time #############

  test "Check the game is at least one hour" do
  	@reservation.time = "13:00:00"
  	@reservation.end_time = "13:30:00"
  	assert_not @reservation.valid?
  end

  # test "game time should be greater than time now" do 

  # end

  ############### Business

  test "Business should be open" do 
  	@reservation.time = "01:00:00"
    @reservation.end_time = "02:00:00"
  	assert_not @reservation.valid?
  end

  test "There should be one reservation possible" do
  	duplicate_res = @reservation.dup
  	@reservation.save
  	assert_not duplicate_res.valid?
  end



end


