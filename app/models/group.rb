class Group < ActiveRecord::Base
	belongs_to :user 
	validates :user_id, presence: true
	validates :title, presence: true, length: { maximum: 50 }
	validates :about, length: { maximum: 250 }
end
