module BusinessesHelper
	def get_monday
		@business.schedules.where(day: "Monday").first
	end

	def get_tuesday
		@business.schedules.where(day: "Tuesday").first
	end

	def get_wednesday
		@business.schedules.where(day: "Wednesday").first
	end

	def get_thursday
		@business.schedules.where(day: "Thursday").first
	end

	def get_friday
		@business.schedules.where(day: "Friday").first
	end

	def get_saturday
		@business.schedules.where(day: "Saturday").first
	end

	def get_sunday
		@business.schedules.where(day: "Sunday").first
	end	

	def get_str_time(time)
		Time.zone.parse(time).strftime("%I:%M %p")
	end
end
