class Schedule < ApplicationRecord
	belongs_to :business
	validates :business_id, presence: true
	validates :day, presence: true
	validates :open_time, presence: true
	validates :close_time, presence: true

	validate :check_day_is_no_duplicate
	validate :check_close_time_should_be_greater_than_open_time

	def check_day_is_no_duplicate
		errors.add(:day, " already exists") unless !is_day_already_exists?
	end

	def check_close_time_should_be_greater_than_open_time
		errors.add(:close_time, " should be greater than open time.") unless is_close_time_greater?
	end

	def is_day_already_exists?
		sc = Schedule.where(business: business_id, day: day)
		if sc.empty?
			return false
		end
		return true
	end

	def is_close_time_greater? 
		if close_time > open_time
			return true
		end
		return false
	end  

end

# TODO: change open and close time to string 18:00
# change from time to string on reservatoin
# change when looking for open businesses