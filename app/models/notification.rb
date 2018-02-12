class Notification < ApplicationRecord
	belongs_to :recipientable, polymorphic: true
    belongs_to :actorable, polymorphic: true
    belongs_to :notifiable, polymorphic: true

    scope :unread, ->{where read_at: nil}
end
