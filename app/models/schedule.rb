class Schedule < ApplicationRecord
	belongs_to :business
	validates :business_id, presence: true
	validates :day, presence: true
	validates :open_time, presence: true
	validates :close_time, presence: true
end

# TODO: change open and close time to string 18:00
# change from time to string on reservatoin
# change when looking for open businesses