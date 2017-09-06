class Game < ActiveRecord::Base
  belongs_to :user
  belongs_to :business
  
  has_many :game_lines, dependent: :destroy
  has_many :comments, as: :commentable

  validates :description, length: { maximum: 500, minimum: 5 }, allow_blank: true
  validates :title, length: { minimum: 5, maximum: 60}, allow_blank: true
  validates :number_players, presence: true, numericality: {only_integer: true}

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

  #validate user
  validate :check_if_user_exists

  #validate number of players
  validate :check_number_players_greater_than_0

  #validate public 
  validate :check_public_is_presence


    ### Validate Date
  	def check_date_later_than_today
  		errors.add(:date, "Date should be today or later") unless date >= Date.today
  	end

    def check_year_not_greater_than_a_year
      errors.add(:date, "Date should not be greater than a year") unless date < Date.today + 1.year
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
      errors.add(:field_id, " this field is reserved at this time") unless is_the_field_reserved_at_this_time?
    end

    ### Valite User

    def check_if_user_exists
      errors.add(:user_id, " the user doesn't exist") unless does_user_exists?
    end

    #### Validate Number of Players 

    def check_number_players_greater_than_0
      errors.add(:number_players, " should be greater than 0") unless number_players > 0
    end

    ####### validate public presence
    def check_public_is_presence
      errors.add(:public, " should be presence") unless !public.nil?
    end
    
  	private

  # 		def have_user_reserved_the_same_date?
  # 			userGames = Game.where(user_id: user_id, date: date)

  # 			if userGames.count > 0
  # 				return false
  # 			end
  # 			return true
  # 		end

  

  ############ GAME ##############



  ############ USER ##############
  def does_user_exists?
    
    if !user_id.nil?
      user = User.where(id: user_id)

      if user.empty?
        return false
      end
    end

    return true
  end

  #maybe check if business id is equal to current business
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

  def is_the_field_reserved_at_this_time?

    games = Game.where(date: date, time: time, business_id: business_id)

    games.each do |game|
      # check first if it is the correct to let update it
      if check_if_the_game_need_to_check_for_field_availability(id, game, date, time, end_time, 
        business_id, field_id)

        if game.field_id == field_id
          return false
        end

      end

    end

    return true
  end

  def check_if_the_game_need_to_check_for_field_availability(id, game, date, time, end_time, business_id, field_id)
    if id.nil?
      return true
    end

    if game.id == id
      if date==game.date && time == game.time && end_time == game.end_time && 
        game.business_id == business_id && game.field_id == field_id
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
    today = Date.today

    if date == today
      d = Time.now

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
		b_open_time = b_open_time.strftime("%H:%M")
		b_close_time = b_close_time.strftime("%H:%M")
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
