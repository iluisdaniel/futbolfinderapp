class Field < ApplicationRecord
	belongs_to :business
	validates :business_id, presence: true
	validates :name, presence: true, length: {maximum: 50}
	validates :price, presence: true, numericality: {greater_than: 0, less_than: 10000}
	validates :description, presence: true
end
