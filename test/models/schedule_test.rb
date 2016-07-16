require 'test_helper'

class ScheduleTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
   def setup
  	@business = businesses(:canchita)
  	@schedule = schedules(:one)
  end

  test "should be valid" do
  	assert @schedule.valid?
  end

   test "business with schdule should be valid" do
  	assert @business.valid?
  end

  test "business id should be present" do
  	@schedule.business_id = nil
  	assert_not @schedule.valid? 
  end

   #should remove all the schedules when a business is delete it" do
  	test "Day should be present" do
  		@schedule.day = "   "
  		assert_not @schedule.valid?, "Day has to be present"
  	end

  	test "Open Time should be present" do
  		@schedule.open_time = nil
  		assert_not @schedule.valid?
  	end

  	test "Close time should be present" do
  		@schedule.day = nil
  		assert_not @schedule.valid? 
  	end

  
end
