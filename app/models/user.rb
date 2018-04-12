class User < ApplicationRecord
	before_save { self.email = email.downcase }
	before_create :create_remember_token
	before_create :randomize_id

	has_many :charges
	has_many :notifications, as: :recipientable
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

	extend FriendlyId
	friendly_id :slug_candidates, use: :slugged

	#TODO VALID_WORD_REGEX = /[a-zA-Z]+/

	validate :check_email_in_business
	validates :first_name, presence: true, length: { maximum: 25 }#, format: { with: VALID_WORD_REGEX }	
	validates :last_name, presence: true, length: { maximum: 25 }
	validates :location, length: { maximum: 30}
	validates :gender, length: { maximum: 6 }
	VALID_PHONE_REGEX = /\d{10}/
	validates :phone, presence: true, length: {maximum: 10, minimum: 10},
						format: { with: VALID_PHONE_REGEX }, uniqueness: true
	# validate :check_date_of_birth

	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	validates :email, presence: true, length: {maximum: 255}, 
			format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }

	has_secure_password
	validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

	# This method associates the attribute ":avatar" with a file attachment
	  has_attached_file :avatar, styles: {
	    thumb: '100x100>',
	    square: '200x200#',
	    medium: '300x300>'
	  }

	  # Validate the attached image is image/jpg, image/png, etc
	  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/


	# # Returns the hash digest of the given string.
	#   def User.digest(string)
	#     cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
	#                                                   BCrypt::Engine.cost
	#     BCrypt::Password.create(string, cost: cost)
	#   end

	def stripe_customer
		if stripe_id?
		  Stripe::Customer.retrieve(stripe_id)
		else
		  stripe_customer = Stripe::Customer.create(email: email)
		  update(stripe_id: stripe_customer.id)
		  stripe_customer
		end
	end

	def User.new_remember_token
	    SecureRandom.urlsafe_base64
	end

	def User.digest(token)
	    Digest::SHA1.hexdigest(token.to_s)
	end

	def User.digest_two(string)
   	 	cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
    	                                              BCrypt::Engine.cost
    	BCrypt::Password.create(string, cost: cost)
  	end

	# to call all your friends

    def friends
      active_friends | received_friends
    end

# to call your pending sent or received

    def pending
        pending_friends | requested_friendships
    end

    def is_a_friend?(user)
    	friends.include?(user)
    end

    def is_a_friend_of_a_friend?(user)
    	friends.each do |friend|
    		if friend.is_a_friend?(user)
    			return true
    		end
    	end
    	return false
    end

    def games_involved
    	Game.joins(game_lines: :user).where(game_lines: {user_id: id, accepted: "Accepted"})
    end

    def invited_games
        Game.joins(game_lines: :user).where(game_lines: {user_id: id, accepted: "Pending" })   
    end

     def slug_candidates
	    [
	      :first_name,
	      [:first_name, :last_name],
	      [:first_name, :last_name, :rand_number]
	    ]
  	end

  	def rand_number
  		rand(100)
  	end

  	def check_date_of_birth
  		if !dob.nil? 
			errors.add(:dob, "User should have at least 13 years old") unless dob < Date.today - 13.years	
		end
	end

	private

		def randomize_id
		  begin
		    self.id = SecureRandom.random_number(1_000_000)
		  end while User.where(id: self.id).exists?
		end

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


