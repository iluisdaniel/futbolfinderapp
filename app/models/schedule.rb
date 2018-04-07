class Schedule < ApplicationRecord
	belongs_to :business, dependent: :destroy
	validates :business_id, presence: true
	validates :day, presence: true
	validates :open_time, presence: true
	validates :close_time, presence: true

end
