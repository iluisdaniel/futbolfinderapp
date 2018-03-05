class CustomVenue < ApplicationRecord
	belongs_to :game, optional: true

	# #DO tests fields validation
	validates :date, presence: true
	validates :time, presence: true
	validates :end_time, presence: true
	validates :address, presence: true, length: {maximum: 255}
	validates :city, length: {maximum: 50}, allow_blank: true
	validates :state, length: {maximum: 50}, allow_blank: true
	validates :zipcode, length: {maximum: 5, minimum: 5}, allow_blank: true
	validates :ground, length: {maximum: 25}, allow_blank: true
	validates :number_players, numericality: {only_integer: true, greater_than: 1, less_than: 23}, allow_blank: true
	validates :field_type, length: {minimum: 6, maximum: 10}, allow_blank: true

	#Validate Date
	validate :check_date_later_than_today
	validate :check_year_not_greater_than_a_year

	# #Validate Time
	validate :check_venue_time_greater_than_time_now
	validate :check_venue_end_time_greater_than_time

	### Validate Date
  	def check_date_later_than_today
  		errors.add(:date, "Date should be today or later") unless date >= Date.today
  	end

    def check_year_not_greater_than_a_year
      errors.add(:date, "Date should not be greater than a year") unless date < Date.today + 1.year
    end

 #    ### Validate Time

  	def check_venue_time_greater_than_time_now
  		errors.add(:time, " should be greater for time now") unless venue_time_greater_than_time_now?
  	end

  	def check_venue_end_time_greater_than_time
  		errors.add(:end_time, " should be greater than start time") unless venue_end_time_greater_than_time?
  	end


  	def venue_time_greater_than_time_now?
	    today = Date.current

	    if date == today
	      d = Time.zone.now

	      if (time.hour <= d.hour)
	        return false
	      end
	    end

	    return true
  	end

  	def venue_end_time_greater_than_time?
  		if end_time <= time
  			return false
  		end

  		return true
  	end
end
