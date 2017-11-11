class Notification < ActiveRecord::Base
	belongs_to :recipientable, polymorphic: true
    belongs_to :actorable, polymorphic: true
    belongs_to :notifiable, polymorphic: true

    scope :unread, ->{where read_at: nil}
end
