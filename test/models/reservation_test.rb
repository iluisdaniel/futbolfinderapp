require 'test_helper'

class ReservationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  


  def setup
  	# @business = businesses(:canchita)
  	# @field = fields(:one)
  	# @schedule = Schedule.new(day: "Tuesday", open_time: "10:00", close_time: "22:00", business: @business)
    date = DateTime.current
    # @schedule = Schedule.new(day: date.strftime("%A"), open_time: "09:00", close_time: "20:00", business: @business)
    # @schedule = schedules(:one)
    # @schedule2 = schedules(:two)

    new_time = date.change(hour: 13, min: 0)
    new_time = new_time + 7.days

  	# @reservation = Reservation.new(time: new_time, 
  		# end_time: new_time + 1.hour, business_id: @business.id, field_id: @field.id)

    @reservation = Reservation.new(time: new_time, 
      end_time: new_time + 1.hour)

    # @reservation.date = get_next_monday_date
    # @reservation.date = Date.parse("21-05-2018")
  end

  test "should be valid" do 
  	assert @reservation.valid?, @reservation.errors.full_messages.to_s
  end

  # test "open_time should be smaller or equal to time" do 
  #   t = Time.parse(@schedule.open_time)
  #   b_open_time = DateTime.new(@reservation.time.year,@reservation.time.month,@reservation.time.day,t.hour,t.min, 0, "-0400")
    
  #   assert b_open_time <= @reservation.time
  # end


  # test "time should be smaller  to close time" do 
  #   t = Time.parse(@schedule.close_time)
  #   b_close_time = DateTime.new(@reservation.time.year,@reservation.time.month,@reservation.time.day,t.hour,t.min, 0, "-0400")
    
  #   assert  @reservation.time < b_close_time
  # end


  # test "end_time should be smaller or equal to close time" do 
  #   t = Time.parse(@schedule.close_time)
  #   b_close_time = DateTime.new(@reservation.time.year,@reservation.time.month,@reservation.time.day,t.hour,t.min, 0, "-0400")
    
  #   assert  @reservation.end_time <= b_close_time
  # end

  ############# Presence ####################

  # test "field should be present" do
  # 	@reservation.field_id = nil
  # 	assert_not @reservation.valid? 
  # end

  ####### Check Date #################

  test "time should be greater than current time" do
  	@reservation.time = DateTime.current - 1.hour
    @reservation.end_time = DateTime.current
  	assert_not @reservation.valid? 
  end

  # test "Check that fails when time is good but has different day" do 
  #   @reservation.time = @reservation.time + 3.day
  #   @reservation.end_time = @reservation.end_time + 3.day
  #   assert_not @reservation.valid? 
  # end


  ############ Time #############

  test "Check the game is at least one hour" do
  	@reservation.end_time = @reservation.end_time - 30.minute
  	assert_not @reservation.valid?
  end

  # test "game time should be greater than time now" do 

  # end

  ############### Business

  # test "Business should not be open | Check before open time" do
  #   new_date = DateTime.current.next_week 
  #   new_time =  DateTime.new(new_date.year,new_date.month,new_date.day, 6, 0)
  # 	@reservation.time = new_time
  #   @reservation.end_time = new_time + 1.hour
  # 	assert_not @reservation.valid?, "time: " + @reservation.time.to_s + 
  #                     " | end_time: " + @reservation.end_time.to_s + 
  #                     " | Schedule " + @schedule.day + " " + @schedule.open_time + 
  #                     " | Date Current " + DateTime.current.to_s
  # end

  test "Business should not be open | Check after closing time" do 
    new_date = DateTime.current.next_week 
    new_time =  DateTime.new(new_date.year,new_date.month,new_date.day, 21, 0)
    @reservation.end_time = new_time + 1.hour
    assert_not @reservation.valid?, @reservation.time
  end

  # test "There should be one reservation possible" do
  # 	duplicate_res = @reservation.dup
  # 	@reservation.save
  # 	assert_not duplicate_res.valid?
  # end

  # test "should be valid when time is 1:00 AM" do 

  #   @reservation.time = @reservation.time + 2.day + 12.hour
  #   @reservation.end_time = @reservation.time + 1.hour

  #   assert @reservation.valid?,  @reservation.errors.full_messages.to_s+ " time: " + @reservation.time.to_s + "  " +@reservation.time.strftime("%A") +
  #                     " | end_time: " + @reservation.end_time.to_s + 
  #                     " | Schedule " + @schedule2.day + " " + @schedule2.open_time + " - " +  @schedule2.close_time + 
  #                     " | Date Current " + DateTime.current.to_s
  # end

  


  # test "should be valid when reserving at 12:00 AM" do 

  #   # Schedule is sunday 10 a 2am
  #   # res lunes a la 00 a 1
  #   t = (@reservation.time + 10.hour).to_s
  #   @reservation.time = @reservation.time + 11.hour + 2.day
  #   @reservation.end_time = @reservation.time + 1.hour

  #   assert @reservation.valid?,  @reservation.errors.full_messages.to_s+ " time: " + @reservation.time.to_s + "  " +@reservation.time.strftime("%A") +
  #                     " | end_time: " + @reservation.end_time.to_s + 
  #                     " | Schedule " + @schedule2.day + " " + @schedule2.open_time + " - " +  @schedule2.close_time + 
  #                     " | Date Current " + DateTime.current.to_s
  # end


  # test "Reservations should't overlap" do
  #   duplicate_res = @reservation.dup
  #   duplicate_res.time = duplicate_res.time - 1.hour
  #   duplicate_res.end_time = duplicate_res.end_time + 1.hour
  #   @reservation.save
  #   assert_not duplicate_res.valid?
  # end

  # test "Reservations should't overlap two" do
  #   duplicate_res = @reservation.dup
  #   duplicate_res.time = duplicate_res.time + 30.minute
  #   duplicate_res.end_time = duplicate_res.end_time + 1.hour
  #   @reservation.save
  #   assert_not duplicate_res.valid?
  # end

  # test "Reservations should't overlap three" do
  #   duplicate_res = @reservation.dup
  #   duplicate_res.time = duplicate_res.time - 1.hour
  #   duplicate_res.end_time = duplicate_res.end_time - 10.minute
  #   @reservation.save
  #   assert_not duplicate_res.valid?
  # end

end


