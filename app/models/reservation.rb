class Reservation < ApplicationRecord
	belongs_to :game, optional: true
	belongs_to :business, optional: true
  has_many :charges, dependent: :nullify
  has_one :checkin_time

  before_create :randomize_id
  # validates :time, uniqueness: {scope: [ :end_time, :field_id ]}
  
	validates :time, presence: true
	validates :end_time, presence: true
	# validates :field_id, presence: true

  #Validate Time
  # validate :check_there_is_no_reservations_overlap
  validate :check_game_is_at_least_one_hour
  validate :check_time_greater_than_current_time
  # validate :check_if_the_business_is_open_at_that_time

  #Validate Field 
  # validate :check_if_the_business_has_fields
  # validate :check_if_field_belongs_to_business
  # validate :check_if_field_is_reserved_on_this_time

  #Validate Business
  # validate :check_if_business_exists

  # CHARGES

  def get_user_charge(user)
    self.charges.where(user: user).first
  end

  def charge_players
    if self.game.nil?
      nil
    else
      gls = self.game.game_lines.where(accepted: "Accepted")
      field = Field.find(self.field_id)
      application_fee = 100 #1dolar
      convert_to_cents = 100

      if self.field_price.nil?
        price_amount = field.price * convert_to_cents
      else
        price_amount = self.field_price
      end

      duration = (self.end_time - self.time) / 3600
      players_with_card = get_number_of_players_with_card(gls)
      amount_by_player = ((( price_amount * duration) / players_with_card.to_f) + application_fee).round

      gls.each do |gl|
        if check_there_is_no_charge(gl.user).empty?
          if gl.user.card_last4
            charge_player(gl, amount_by_player, application_fee, "Successful")
          end
        end
      end
    end
  end

  def get_number_of_players_with_card(game_lines)
    n = 0
    game_lines.each do |gl|
      if gl.user.card_last4
        n = n + 1
      end
    end
    return n
  end

  def check_there_is_no_charge(player)
    self.charges.where(user: player)
  end

  def charge_player(gl, amount, fee, msg)
    begin
      token = Stripe::Token.create({
        customer: gl.user.stripe_id
        }, {stripe_account: self.business.stripe_user_id})

      charge = Stripe::Charge.create({
        :amount => amount,
        :currency => "usd",
        :source => token,
        :application_fee => fee,
      }, :stripe_account => self.business.stripe_user_id)

      # if created save charge on charges table. Save charge id, amount, 
      c = self.charges.build(stripe_id: charge.id, business: self.business, user: gl.user, 
        status: msg, amount: amount, application_fee: fee, card_brand: charge.source.brand,
        card_last4: charge.source.last4, card_exp_month: charge.source.exp_month, card_exp_year: charge.source.exp_year)
      c.save
      Notification.create(recipientable: gl.user, actorable: self.business, 
                        action: "Charged you " + ActionController::Base.helpers.number_to_currency(amount / 100) + " for ", notifiable: gl.game)
    rescue Stripe::InvalidRequestError, Stripe::CardError => e
      # update charge with error
      c = self.charges.build(business: self.business, user: gl.user, 
        status: "Error", amount: amount, application_fee: fee, error_msg: e.to_s)
      c.save
      Notification.create(recipientable: gl.user, actorable: self.business, 
                        action: "There was an error with your card. Please, contact ", notifiable: gl.game)
    end
  end

  def charge_penalty
    amount = 3500
    application_fee = 100
    charge_player(self.game.user, amount, application_fee, "Penalty")
  end

  #FILTER

  def self.filterReservations(business, date, field, username, page)
    # all empty
    if date.empty? && field.empty? && username.empty?
      Reservation.where(business:business).order(date: :desc, time: :desc).paginate(page: page, per_page:15)
    # filter with date
    elsif !date.empty? && field.empty? && username.empty?
      findReservationsWithDate(business, date, page)
    # filter with field
    elsif !field.empty? && date.empty? && username.empty?
      findReservationsWithField(business, field, page)
      #filter with username
    elsif !username.empty? && date.empty? && field.empty?
      findReservationsWithUsername(business, username, page)
    #filter with username and date
    elsif !username.empty? && !date.empty? && field.empty?
      findReservationsWithDateAndUsername(business, date, username, page)
    #filter with username and field
    elsif date.empty? && !field.empty? && !username.empty?
      findReservationsWithUsernameAndField(business, field, username, page)
    #filter with date and field
    elsif !date.empty? && !field.empty? && username.empty?
      findReservationsWithDateAndField(business, field, date, page)
    #filter with all
    elsif !date.empty? && !field.empty? && !username.empty?
      findReservationsWithDateAndUsernameAndField(business, date, field, username, page)
    end
  end

  def self.findReservationsWithDate(business, date, page)
    d = Date.parse(date)
    Reservation.where(business: business, date: d).order(time: :desc).paginate(page: page, per_page:15)
  end

  def self.findReservationsWithField(business, field, page)
    Reservation.where(business: business, field_id: field).order(date: :desc, time: :desc)
                                                          .paginate(page: page, per_page:15)
  end

  def self.findReservationsWithUsername(business, username, page)
    u = User.friendly.find(username)
    res = Reservation.where(business: business)
    res.includes(:game).references(:game)
    .where('games.user_id', u)
    .order(date: :desc, time: :desc)
    .paginate(page: page, per_page:15)
    rescue ActiveRecord::RecordNotFound
       nil
  end

  def self.findReservationsWithDateAndUsername(business, date, username, page)
    d = Date.parse(date)
    u = User.friendly.find(username)
    res = Reservation.where(business: business, date: d)
    res.includes(:game).references(:game)
    .where('games.user_id', u)
    .order(date: :desc, time: :desc)
    .paginate(page: page, per_page:15)
    rescue ActiveRecord::RecordNotFound
       nil
  end

  def self.findReservationsWithUsernameAndField(business, field, username, page)
    u = User.friendly.find(username)
    res = Reservation.where(business: business, field_id: field)
    res.includes(:game).references(:game)
    .where('games.user_id', u)
    .order(date: :desc, time: :desc)
    .paginate(page: page, per_page:15)
    rescue ActiveRecord::RecordNotFound
       nil
  end

  def self.findReservationsWithDateAndField(business, field, date, page)
    d = Date.parse(date)
    Reservation.where(business: business, date: d, field_id: field)
                .order(date: :desc, time: :desc)
                .paginate(page: page, per_page:15)
  end

  def self.findReservationsWithDateAndUsernameAndField(business, date, field, username, page)
    d = Date.parse(date)
    u = User.friendly.find(username)
    res = Reservation.where(business: business, date: d, field_id: field)
    res.includes(:game).references(:game)
    .where('games.user_id', u)
    .order(date: :desc, time: :desc)
    .paginate(page: page, per_page:15)
    rescue ActiveRecord::RecordNotFound
       nil
  end

    #validation

    def check_there_is_no_reservations_overlap
      errors.add(:time, "There is a game at that time") unless !are_there_any_overlaps?
    end


    ### Validate Date
  	def check_time_greater_than_current_time
  		errors.add(:date, "Time should be greater than current time") unless time >= DateTime.current
  	end

    ### Validate Time
  	def check_game_is_at_least_one_hour
  		errors.add(:end_time, "A game should be at least for an hour") unless game_time_greater_than_one_hour?
  	end

  	## Validate business Schedule
    def check_if_the_business_is_open_at_that_time
  		if !business_id.nil?
        errors.add(:time, " business is close at that time") unless is_it_open?
      end
  	end

    def check_if_business_exists
      if !business_id.nil?
        errors.add(:business_id, " the business doesn't exist") unless does_business_exists?
      end
    end


    ### Validate Fields
    def check_if_the_business_has_fields
      if !business_id.nil?
        errors.add(:field_id, " The business doesn't have any fields") unless does_the_business_has_fields?
      end
    end

    def check_if_field_belongs_to_business
      if !business_id.nil?
        errors.add(:field_id, " this field doesn't belong to the business") unless does_the_field_belongs_to_business?
      end
    end

    def check_if_field_is_reserved_on_this_time
      errors.add(:field_id, " this field is reserved at this time") unless is_the_field_available_at_this_time?
    end

    def self.current
      where("date >= ?", Date.current).order(date: :asc)
    end

    def self.past
      where("date < ?", Date.current).order(date: :desc)
    end

    def start_time
         self.date ##Where 'start' is a attribute of type 'Date' accessible through MyModel's relationship
    end

    def date_and_time_to_date_time(d,t)
      return DateTime.new(d.year, d.month, d.day, t.hour, t.min, t.sec, t.zone)
    end

    def overlap_between_times?(time, end_time, time_to_compare, end_time_to_compare)
      if ((time_to_compare <= time) && (end_time_to_compare >= end_time)) || 
            ((time_to_compare >= time) && (time_to_compare < end_time)) ||
            ((end_time_to_compare > time) && (end_time_to_compare <= end_time))
        return true
      end 
      return false
    end

  
  	private

    def are_there_any_overlaps?
      reservations = Reservation.where(time: time.beginning_of_day..time.end_of_day)
      if reservations.empty?
        return false
      end


      reservations.each do |res|
        if overlap_between_times?(time, end_time, res.time, res.end_time)
          return true
        end
      end

      return false

    end

    def randomize_id
        begin
          self.id = SecureRandom.random_number(1_000_000)
        end while Game.where(id: self.id).exists?
    end

  #aybe user can reserved only a game each day

  ############ FIELDS ##############

  def does_the_business_has_fields?
    fields = Field.where(business_id: business_id)

    if fields.empty?
      return false
    end
      return true
  end

  def does_the_field_belongs_to_business?
    field = Field.where(id: field_id ,business_id: business_id)

    if field.empty?
      return false
    end

    return true
  end

  def is_the_field_available_at_this_time?
  rss = Reservation.where(date: date, business_id: business_id, field_id: field_id)

    rss.each do |rs|
        if !((end_time.strftime("%H:%M") <= rs.time.strftime("%H:%M")) || (time.strftime("%H:%M") >= rs.end_time.strftime("%H:%M"))) 
          return false
        end
    end
    return true
  end

  ######### TIME ################

  def game_time_greater_than_one_hour?
    time_test = time + 1.hour


    # t = time.to_i
    # t_end =  end_time.to_i

    # if t_end - t < 3600
    if time_test <= end_time
     return true
    end

    return false
  end

  ######### Check Business Schedule ######################

  def does_business_exists?
    business = Business.where(id: business_id)

    if business.empty?
      return false
    end

    return true
  end

  def is_it_open?
    # TO-DO: We shouldn't check for schedule.many?, since we are planning to have one only schedule for day for business. 
      
        
      # Check if time is before 6 am, it should check for the day before instead. 
      # for example: business input schedule 10 to 2 am. the 2 am is alreday the next day.
      if time.hour < 6
        day = (time - 1.day).strftime("%A")
      else
        day = time.strftime("%A")
      end


     # logger.info " **************

     #  here 

     # "

    schedule = Schedule.where(business_id: business_id, day: day).first

    # logger.info " **************

    #   day #{day}
    #   schedule #{schedule.day.to_s unless schedule.nil?}

      
    #  "

    # check if there are schedules for the date of the game
    if !schedule.nil?
        return compare_times?(schedule.open_time, schedule.close_time, schedule.day)
    else
      return false
    end
  end

	#returns true if game time is in between the open time and close time
  # TODO: When we change how time zones are handled (ex: by each user) we need to adapt this method
	def compare_times?(b_open_time_str, b_close_time_str, day)
    # logger.info "*********************************************"
    # logger.info "               "

    d = 0
    if time.hour < 6
      d = 1
    end 

    t = Time.parse(b_open_time_str)
    b_open_time = DateTime.new(time.year,time.month,time.day - d,t.hour,t.min, 0, "-0400")

    t_end = Time.parse(b_close_time_str)
    b_close_time = DateTime.new(time.year,time.month,time.day - d,t_end.hour,t_end.min, 0, "-0400")

    if b_close_time_str < b_open_time_str
        b_close_time = b_close_time + 1.day
    end

    # first = false
    # second = false
    # third = false

    # if b_open_time <= time
    #   first = true
    # end

    # if time <= b_close_time
    #   second = true
    # end

    # if end_time <= b_close_time
    #   third = true
    # end

    # logger.info "
    #     Variables:

    #         time #{time.to_s}
    #         end_time #{end_time.to_s}

    #         day #{day}
    #         b_open_time_str #{b_open_time_str}
    #         b_close_time_str #{b_close_time_str}

    #         t #{t.to_s}
    #         t_end #{t_end.to_s}

    #         b_open_time #{b_open_time.to_s}
    #         b_close_time #{b_close_time.to_s}

    #         first #{first.to_s}
    #         second #{second.to_s}
    #         third #{third.to_s}

                    
    #  "


		if (b_open_time <= time) && (time < b_close_time) && 
			(end_time <= b_close_time)
			return true
    elsif (end_time <= b_close_time) && 
      (time - 1.day).strftime("%A") == b_open_time.strftime("%A")
        return true
		else
			return false
		end
	end
end
