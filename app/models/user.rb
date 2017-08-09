class User < ActiveRecord::Base
	before_save { self.email = email.downcase }
	before_create :create_remember_token

	has_many :groups
	has_many :group_lines, dependent: :destroy
	has_many :games, dependent: :destroy
	has_many :game_lines, dependent: :destroy
	has_many :friendships, dependent: :destroy
    has_many :received_friendships, class_name: "Friendship", foreign_key: "friend_id"
    has_many :active_friends, -> { where(friendships: { accepted: true}) }, through: :friendships, source: :friend
    has_many :received_friends, -> { where(friendships: { accepted: true}) }, through: :received_friendships, source: :user
    has_many :pending_friends, -> { where(friendships: { accepted: false}) }, through: :friendships, source: :friend
    has_many :requested_friendships, -> { where(friendships: { accepted: false}) }, through: :received_friendships, source: :user

	validate :check_email_in_business
	validates :name, presence: true, length: { maximum: 50 }
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	validates :email, presence: true, length: {maximum: 255}, 
			format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }

	has_secure_password
	validates :password, presence: true, length: { minimum: 6 }, allow_nil: true


	def User.new_remember_token
	    SecureRandom.urlsafe_base64
	end

	def User.digest(token)
	    Digest::SHA1.hexdigest(token.to_s)
	end

	# to call all your friends

    def friends
      active_friends | received_friends
    end

# to call your pending sent or received

    def pending
        pending_friends | requested_friendships
    end

	private

		def create_remember_token
	      self.remember_token = User.digest(User.new_remember_token)
	    end

	    def check_email_in_business
	    	email = Business.find_by_email(self.email)
	    	if  email != nil 
	    		errors.add(:email, "There is a Business using the same email.")
	    	end 
	    end

end
