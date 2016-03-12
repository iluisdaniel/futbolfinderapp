class Business < ActiveRecord::Base
	attr_accessor :remember_token
	before_save { self.email = email.downcase }
	validates :name, presence: true, length: {maximum: 50}
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
	validates :password, presence: true, length: { minimum: 6 }

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

end
