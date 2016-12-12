class Game < ActiveRecord::Base
  belongs_to :user
  belongs_to :business
  validates  :user_id, presence: true
  validates :business_id, presence: true
  validates :field_id, presence: true
end


