class Charge < ApplicationRecord
  belongs_to :business
  belongs_to :user, optional: true
  belongs_to :reservation, optional: true

  def receipt
  	if reservation_id && user_id
  		Receipts::Receipt.new(
  			id: id,
  			product: "Reservation " + reservation_id.to_s,
  			company: {
	        name: "Futfinder",
	        address: "123 Example Street",
	        email: "support@example.com"
	      },
	       line_items: [
	        ["Date", created_at.to_s],
	        ["Account Billed", user.email],
	        ["Item", "Game at " + business.name],
	        ["Game", reservation.game.id.to_s],
	        ["Amount", ActionController::Base.helpers.number_to_currency(amount / 100)],
	        ["Card Charged", "#{card_brand} (**** **** **** #{card_last4})"]
	      ]
  		)
  	else
	    Receipts::Receipt.new(
	      id: id,
	      product: "Futfinder Supscription",
	      company: {
	        name: "Futfinder",
	        address: "123 Example Street",
	        email: "support@example.com"
	      },
	      line_items: [
	        ["Date", created_at.to_s],
	        ["Account Billed", business.email],
	        ["Product", "Store subscription"],
	        ["Amount", ActionController::Base.helpers.number_to_currency(amount / 100)],
	        ["Card Charged", "#{card_brand} (**** **** **** #{card_last4})"]
	      ]
	    )
	end
  end
end
