class Game < ActiveRecord::Base
  belongs_to :user
  belongs_to :business
  validates  :user_id, presence: true
  validates :business_id, presence: true
  validates :field_id, presence: true

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

  

  # validate :check_fields_are_availble_at_that_time
  # validate :check_if_field_is_reserverd
  # validate :check_if_field_id_belongs_to_buesiness
  # validate :check_if_user_have_reserve_a_game_that_date
  # validate :check_if_there_are_fields_with_that_number_of_players_available


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
  		errors.add(:time, " business is close at that time") unless is_it_open?
  	end

    ### Validate Fields
    def check_if_the_business_has_fields
      errors.add(:field_id, " The business doesn't have any fields") unless does_the_business_has_fields?
    end

    def check_if_field_belongs_to_business
      errors.add(:field_id, " this field doesn't belong to the business") unless does_the_field_belongs_to_business?
    end

    def check_if_field_is_reserved_on_this_time
      errors.add(:field_id, " this field is reserved at this time") unless is_the_field_reserved_at_this_time?
    end

  # 	def check_fields_are_availble_at_that_time
  # 		errors.add(:date, "there are no fiels availble at that time") unless are_fields_available_at_that_time?
  # 	end

  # 	### Validate field 
  #   def check_if_field_id_belongs_to_buesiness
  #     errors.add(:field_id, "This field doesn't belong to the business") unless is_field_id_correct?
  #   end

  #   ### Validate availability
  #   def check_if_field_is_reserverd
  # 		errors.add(:field_id, "the field is reserved already") unless is_field_reserved?
  # 	end

  # 	def check_if_user_have_reserve_a_game_that_date
  # 		errors.add(:date, "An user can have two reservations the same date") unless have_user_reserved_the_same_date?
  # 	end

  #   def check_if_there_are_fields_with_that_number_of_players_available
  #     errors.add(:number_players, "There is no fields available right now") unless are_there_any_fields_available?
  #   end

  	private

  #     def are_there_any_fields_available?
  #       games = Game.where(date:date, time:time, number_players: number_players)

  #       fields = Field.where(business_id: business_id, number_players: number_players)

  #       if games.count < fields.count
  #         return false
  #       end

  #       return true
  #     end

  # 		def have_user_reserved_the_same_date?
  # 			userGames = Game.where(user_id: user_id, date: date)

  # 			if userGames.count > 0
  # 				return false
  # 			end
  # 			return true
  # 		end

  

  ############ GAME ##############



  ############ USER ##############

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
      if game.field_id == field_id
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
