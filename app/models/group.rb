class Group < ActiveRecord::Base
	belongs_to :user 
	has_many :group_lines, dependent: :destroy
	has_many :comments, as: :commentable
	validates :user_id, presence: true
	validates :title, presence: true, length: { maximum: 50 }
	validates :about, length: { maximum: 250 }
end
