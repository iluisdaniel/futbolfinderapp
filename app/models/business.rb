class Business < ActiveRecord::Base
	before_save { self.email = email.downcase }
	validates :name, presence: true, length: {maximum: 50}
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
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

end
