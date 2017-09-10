class Business < ActiveRecord::Base
	attr_accessor :remember_token
  has_many :schedules, dependent: :destroy
  has_many :fields, dependent: :destroy
  has_many :games, dependent: :destroy
  has_many :reservations, dependent: :destroy
	extend FriendlyId
	friendly_id :slug_candidates, use: :slugged
	before_save { self.email = email.downcase }
	validates :name, presence: true, length: {maximum: 50}
	validate :check_email_in_user
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
	validates :email, presence: true, length: {maximum: 255},
					  format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }
	validates :phone, presence: true, length: {maximum: 10, minimum: 10},
						uniqueness: true
	validates :address, presence: true, length: {maximum: 255}
	validates :city, presence: true, length: {maximum: 50}
	validates :state, presence: true, length: {maximum: 50}
	validates :zipcode, presence: true, length: {maximum: 5, minimum: 5}
	has_secure_password
	validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

	# Return the hash digest of the given string
	def Business.digest(string)
	    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
	                                                  BCrypt::Engine.cost
	    BCrypt::Password.create(string, cost: cost)
  	end

  	#Returns a random token
  	def Business.new_token
  		SecureRandom.urlsafe_base64
  	end

  	# Remembers a Business in the database for use in persistent sessions.
  def remember
    self.remember_token = Business.new_token
    update_attribute(:remember_digest, Business.digest(remember_token))
  end

  # Returns true if the given token matches the digest.
  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

   # Forgets a user.
  def forget
    update_attribute(:remember_digest, nil)
  end

  def should_generate_new_friendly_id?
  	new_record?
  end

   def slug_candidates
    [
      :name,
      [:name, :city],
      [:name, :zipcode, :city],
      [:name, :zipcode, :city, :state]
    ]
  end

  def check_email_in_user
        email = User.find_by_email(self.email)
        if  email != nil 
          errors.add(:email, "There is a User using the same email.")
        end 
  end

end
