class Charge < ApplicationRecord
  before_create :randomize_id

  belongs_to :business
  belongs_to :user, optional: true
  belongs_to :reservation, optional: true

  def receipt
  	if reservation_id && user_id
      application_fee = 100
  		Receipts::Receipt.new(
  			id: id,
  			product: "Reservation " + reservation_id.to_s,
  			company: {
	        name: "Futfinder",
	        address: "123 Example Street",
	        email: "support@example.com"
	      },
	       line_items: [
	        ["Status", status],
          ["Date", created_at.to_s],
	        ["Account Billed", user.email],
	        ["Item", "Game at " + business.name],
	        ["Game", reservation.game.id.to_s],
	        ["Amount", ActionController::Base.helpers.number_to_currency(( amount - application_fee) / 100)],
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
	        ["Amount", ActionController::Base.helpers.number_to_currency( amount / 100)],
	        ["Card Charged", "#{card_brand} (**** **** **** #{card_last4})"]
	      ]
	    )
	   end
  end

  def self.findCharges(date, game_or_reservation, business_or_username, current_user_or_business, page)
    # check if we are looking for business
    if current_user_or_business.instance_of? Business
      # if all empty search for all charges for business
      if date.empty? && game_or_reservation.empty? && business_or_username.empty?
         findBusinessCharges(current_user_or_business, page)
      # only date
      elsif !date.empty? && game_or_reservation.empty? && business_or_username.empty?
        findBusinessChargesWithDate(current_user_or_business, date, page)
      # date and reservation
      elsif  !date.empty? && !game_or_reservation.empty? && business_or_username.empty?
          findBusinessChargesWithDateAndReservation(current_user_or_business,date,game_or_reservation, page)
      # search with all
      elsif  !date.empty? && !game_or_reservation.empty? && !business_or_username.empty?
        findBusinessChargesWithDateReservationAndUsername(current_user_or_business,date,game_or_reservation, 
                                                          business_or_username, page)
      # only reservation
      elsif !game_or_reservation.empty? && date.empty? && business_or_username.empty?
        findBusinessChargesWithReservation(current_user_or_business, game_or_reservation, page)
      # only username
      elsif !business_or_username.empty? && game_or_reservation.empty? && date.empty?
        findBusinessChargesWithUsername(current_user_or_business, business_or_username, page)
      # username and reservation
      elsif !business_or_username.empty? && !game_or_reservation.empty? && date.empty?
        findBusinessChargesWithReservationAndUsername(current_user_or_business, game_or_reservation, 
                                                      business_or_username, page)
      #date and username
      elsif !date.empty? && !business_or_username.empty? && game_or_reservation.empty?
        findBusinessChargesWithDateAndUsername(current_user_or_business, date, business_or_username, page)
      end
      # check if we are searching for User
    elsif current_user_or_business.instance_of? User
      # return all if all params empty
      if date.empty? && game_or_reservation.empty? && business_or_username.empty?
         findUserCharges(current_user_or_business, page)
      # only date
      elsif !date.empty? && game_or_reservation.empty?
       findUserChargesWithDate(current_user_or_business, date, page)
       # date and game
      elsif  !date.empty? && !game_or_reservation.empty?
          findUserChargesWithDateAndGame(current_user_or_business,date,game_or_reservation, page)
      elsif !game_or_reservation.empty? && date.empty?
            findUserChargesWithReservation(current_user_or_business, game_or_reservation, page)
      end   
    end
        
  end
  #User Search Feature
  def findUserCharges(user, page)
    Charge.where(business: user.id).paginate(page: page, per_page: 15)
  end

  def self.findUserChargesWithDate(user, date, page)
    d = Date.parse(date) 
    Charge.where(user: user.id, created_at: d.beginning_of_day..d.end_of_day)
     .paginate(page: page, per_page: 15)
  end

  def self.findUserChargesWithDateAndGame(user,date, game, page)
    d = Date.parse(date)
    g = Game.find(game) 
    Charge.where(user: user.id, created_at: d.beginning_of_day..d.end_of_day, reservation: g.reservation.id)
     .paginate(page: page, per_page: 15)
  end

  def self.findUserChargesWithReservation(user, game, page)
    g = Game.find(game)
    Charge.where(user: user.id, reservation: g.reservation.id)
     .paginate(page: page, per_page: 15)
  end

  #Business Search FEature

  def self.findBusinessCharges(business, page)
    Charge.where(business: business.id).paginate(page: page, per_page: 15)
  end

  def self.findBusinessChargesWithDate(business, date, page)
    d = Date.parse(date) 
    Charge.where(business: business.id, created_at: d.beginning_of_day..d.end_of_day)
     .paginate(page: page, per_page: 15)
  end

  def self.findBusinessChargesWithReservation(business, reservation, page)
    Charge.where(business: business.id, reservation: reservation)
     .paginate(page: page, per_page: 15)
  end

  def self.findBusinessChargesWithUsername(business, username, page)
    u = User.friendly.find(username)
    Charge.where(business: business.id, user: u)
     .paginate(page: page, per_page: 15)
     rescue ActiveRecord::RecordNotFound
       nil
  end

  def self.findBusinessChargesWithDateAndReservation(business,date, reservation, page)
    d = Date.parse(date) 
    Charge.where(business: business.id, created_at: d.beginning_of_day..d.end_of_day, reservation: reservation)
     .paginate(page: page, per_page: 15)
  end

  def self.findBusinessChargesWithReservationAndUsername(business, reservation,username, page)
    u = User.friendly.find(username)
    Charge.where(business: business.id, reservation: reservation, user: u)
     .paginate(page: page, per_page: 15)
     rescue ActiveRecord::RecordNotFound
       nil
  end

  def self.findBusinessChargesWithDateAndUsername(business,date, username, page)
    d = Date.parse(date) 
    u = User.friendly.find(username)
    Charge.where(business: business.id, created_at: d.beginning_of_day..d.end_of_day, user: u)
     .paginate(page: page, per_page: 15)
     rescue ActiveRecord::RecordNotFound
       nil
  end

  def self.findBusinessChargesWithDateReservationAndUsername(business,date, reservation,username, page)
    d = Date.parse(date) 
    u = User.friendly.find(username)
    Charge.where(business: business.id, created_at: d.beginning_of_day..d.end_of_day, 
      reservation: reservation, user: u)
     .paginate(page: page, per_page: 15)
     rescue ActiveRecord::RecordNotFound
       nil
  end

  private

  def randomize_id
      begin
        self.id = SecureRandom.random_number(1_000_000)
      end while Charge.where(id: self.id).exists?
    end
end
