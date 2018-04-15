module ChargesHelper
	def get_charge_amount(c)
		if signed_in?
			return c.amount / 100.00 
		elsif logged_in?
			return 	(c.amount - c.application_fee) / 100.00 unless c.application_fee.nil?
			return c.amount / 100.00 
		end	
	end
end