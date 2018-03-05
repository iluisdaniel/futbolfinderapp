require 'test_helper'

class CustomVenueTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  def setup
  	@user = users(:jose)
  	@game = Game.new( user_id: @user.id, title: "Esto es una prueba", description: "This is the description", 
      number_players: 10, public: "Public", invite_allowed: true)
  	@cv = CustomVenue.new(number_players: 10, ground: "Grass", field_type: "Indoor", address: "Case de manuel", city: "Miami", 
  		state: "Florida", zipcode: "33178", date: 1.day.from_now, time: "13:00:00", end_time: "14:00:00", game_id: @game.id)
  end

  test "should be valid" do 
  	assert @cv.valid?
  end

  test "should be valid with only address, date, time, end time" do
  	@cv.number_players = nil
  	@cv.ground = ""
  	@cv.field_type = ""
  	@cv.city = ""
  	@cv.state = ""
  	@cv.zipcode = ""
  	assert @cv.valid?
  end

  test "should just one venue be related to game" do 
  	cv2 = @cv.dup
  	@cv.save
  	assert_not cv2.valid?
  end

  # Presence

  # test "date should be present" do 
  # 	@cv.date = nil
  # 	assert_not @cv.valid?
  # end

  # test "time should be present" do 
  # 	@cv.time = nil
  # 	assert_not @cv.valid?
  # end

  test "address should be present" do 
  	@cv.address = ""
  	assert_not @cv.valid?
  end

  # Length

  test "address should be less than 255" do 
  	@cv.address = "a" * 256
  	assert_not @cv.valid?
  end

  test "city should be less than 50" do 
  	@cv.city = "a" * 51
  	assert_not @cv.valid?
  end

  test "state should be less than 50" do 
  	@cv.state = "a" * 51
  	assert_not @cv.valid?
  end

  test "zipcode should be more than 5" do 
  	@cv.zipcode = "a" * 6
  	assert_not @cv.valid?
  end

  test "zipcode should be less than 5" do 
  	@cv.zipcode = "a" * 4
  	assert_not @cv.valid?
  end

  test "ground should be less than 25" do 
  	@cv.ground = "a" * 26
  	assert_not @cv.valid?
  end

  test "field_type should be more than 5" do 
  	@cv.field_type = "a" * 5
  	assert_not @cv.valid?
  end

  test "field_type should be less than 10" do 
  	@cv.field_type = "a" * 11
  	assert_not @cv.valid?
  end


  #number

  test "number_players should be a number" do 
  	@cv.number_players = "a"
  	assert_not @cv.valid?
  end

  test "number_players should be less than 23" do 
  	@cv.number_players = 23
  	assert_not @cv.valid?
  end

  test "number_players should be greater than 1" do 
  	@cv.number_players = 1
  	assert_not @cv.valid?
  end

  #date

  test "date should be today or later" do 
  	@cv.date = "2017-12-04"
  	assert_not @cv.valid?
  end

  test "date should not be greater than a year" do
  	@cv.date = Date.tomorrow + 1.years
  	assert_not @cv.valid?
  end

  #time

  test "Check the venue time is greater than time now" do
  	@cv.date = Date.current
  	@cv.time = Time.zone.now - 1.hour
  	assert_not @cv.valid?
  end


end