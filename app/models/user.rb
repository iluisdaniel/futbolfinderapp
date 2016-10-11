class User < ActiveRecord::Base
	before_save { self.email = email.downcase }
	before_create :create_remember_token
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
