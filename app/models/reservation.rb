class Reservation < ApplicationRecord
	belongs_to :game, optional: true
	belongs_to :business
  has_many :charges

  before_create :randomize_id
  validates :date, uniqueness: {scope: [ :time, :end_time, :field_id ]}
  
  validates :date, presence: true
	validates :time, presence: true
	validates :end_time, presence: true
	validates :field_id, presence: true
	validates :business_id, presence: true

	#Validate Date
  validate :check_date_later_than_today
  validate :check_year_not_greater_than_a_year

  #Validate Time
  validate :check_game_is_at_least_one_hour
  validate :check_game_time_greater_than_time_now
  validate :check_if_the_business_is_open_at_that_time

  #Validate Field 
  validate :check_if_the_business_has_fields
  validate :check_if_field_belongs_to_business
  validate :check_if_field_is_reserved_on_this_time

  #Validate Business
  validate :check_if_business_exists

  def charge_players
    if self.game.nil?
      nil
    else
      gls = self.game.game_lines.where(accepted: "Accepted")
      field = Field.find(self.field_id)
      application_fee = 100 #1dolar
      amount_by_player = (field.price / gls.count)

      gls.each do |gl|
        if check_there_is_no_charge(gl.user).empty?
          charge_player(gl.user, amount_by_player, application_fee)
        end
      end
      
    end
  end

  def check_there_is_no_charge(player)
    self.charges.where(user: player)
  end

  def charge_player(player, amount, fee)
    begin
      token = Stripe::Token.create({
        customer: player.stripe_id
        }, {stripe_account: self.business.stripe_user_id})

      charge = Stripe::Charge.create({
        :amount => amount,
        :currency => "usd",
        :source => token,
        :application_fee => fee,
      }, :stripe_account => self.business.stripe_user_id)

      # if created save charge on charges table. Save charge id, amount, 
      c = self.charges.build(stripe_id: charge.id, business: self.business, user: player, 
        status: "Success", amount: amount, application_fee: fee, card_brand: charge.source.brand,
        card_last4: charge.source.last4, card_exp_month: charge.source.exp_month, card_exp_year: charge.source.exp_year)
      c.save
    rescue Stripe::InvalidRequestError, Stripe::CardError => e
      # update charge with error
      c = self.charges.build(business: self.business, user: player, 
        status: "Error", amount: amount, error_msg: e.to_s)
      c.save
    end
  end

    ### Validate Date
  	def check_date_later_than_today
  		errors.add(:date, "Date should be today or later") unless date >= Date.current
  	end

    def check_year_not_greater_than_a_year
      errors.add(:date, "Date should not be greater than a year") unless date < Date.current + 1.year
    end

    ### Validate Time
  	def check_game_is_at_least_one_hour
  		errors.add(:end_time, "A game should be at least for an hour") unless game_time_greater_than_one_hour?
  	end

  	def check_game_time_greater_than_time_now
  		errors.add(:time, " should be greater for time now") unless game_time_greater_than_time_now?
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
      where("date > ?", Date.current).order(date: :asc)
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

  
  	private

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
        if !((end_time <= rs.time) || (time >= rs.end_time)) 
          return false
        end
    end
    return true
  end

  ######### TIME ################

  def game_time_greater_than_one_hour?
    t = time.to_i
    t_end =  end_time.to_i

    if t_end - t < 3600
     return false
    end

    return true
  end

  def game_time_greater_than_time_now?
    today = Date.current

    if date == today
      d = Time.current

      if (time.hour <= d.hour)
        return false
      end
    end

    return true
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
    day = date.strftime("%A")
    schedule = Schedule.where(business_id:business_id, day: day)

    # check if there are schedules for the date of the game
    if !schedule.empty?
      schedule_to_hash = schedule.as_json

      if schedule.many?
        # check in all the times
        is_open = false

        for i in 0..schedule.count - 1
          is_open = compare_times?(schedule_to_hash[i]['open_time'], 
          schedule_to_hash[i]['close_time'], 
          time, end_time, day)

          if is_open == true 
            break
          end	
        end

        return is_open
      else
        #just one scheudle for day
        return compare_times?(schedule_to_hash[0]['open_time'], 
        schedule_to_hash[0]['close_time'], 
        time, end_time, day)
      end
    else
      return false
    end
  end

	#returns true if game time is in between the open time and close time
	def compare_times?(b_open_time,b_close_time, g_time, g_end_time, day)
		b_open_time = b_open_time
		b_close_time = b_close_time
		g_time = g_time.strftime("%H:%M")
		g_end_time = g_end_time.strftime("%H:%M")


		if (b_open_time <= g_time) && (g_time <= b_close_time) && 
			(g_end_time <= b_close_time)
			return true
		else
			return false
		end
	end
end
