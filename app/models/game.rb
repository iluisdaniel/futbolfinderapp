class Game < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :business, optional: true, dependent: :destroy

  #BUG: it doesnt work for users. only for businesses for some reason.
  before_create :randomize_id
  before_save :set_defaults, if: :new_record?

  has_one :reservation, :dependent => :destroy
  has_one :custom_venue, :dependent => :destroy
  
  has_many :game_lines, dependent: :destroy
  has_many :comments, as: :commentable

  validates :description, presence: true, length: { maximum: 500, minimum: 6 }
  validates :title, presence: true, length: { minimum: 4, maximum: 60}
  validates :number_players, presence: true, numericality: {only_integer: true}
  validates :public, presence: true, length: {minimum:3, maximum:20}

  #validate public 
  validate :check_invite_allowed_presence
  

    ####### validate public presence

    def check_invite_allowed_presence
      errors.add(:invite_allowed, " should present") unless !invite_allowed.nil?
    end


    def self.withReservationOrVenue(user_business, page)
      gs = get_games(user_business)

      if user_business.instance_of? Business
        gs.includes(:reservation).references(:reservation)
          .where('reservations.id IS NOT NULL AND reservations.date >= ?', Date.current)
          .order("reservations.date asc")
          .paginate(page: page, per_page: 10)
      else
        gs.includes(:reservation, :custom_venue).references(:reservation, :custom_venue)
            .where('reservations.id IS NOT NULL OR custom_venues.id IS NOT NULL')
            .where('reservations.date >= ? OR custom_venues.date >= ?', Date.current, Date.current)
            .order("reservations.date asc", "custom_venues.date asc")
            .paginate(page: page, per_page: 10)
      end

      # gs.includes(:reservation).references(:reservation)
      #     .where('reservations.id IS NOT NULL AND reservations.date >= ?', Date.current)
      #     .order("reservations.date asc")
    end

    def self.FindGames(user_business, date, public_or_private, current_or_completed, page)
    	if date.empty? && current_or_completed.empty? && !public_or_private.empty? 
    		searchPublicOrPrivateWithReservationOrVenue(user_business, public_or_private, page)
		elsif public_or_private.empty? && date.empty? && !current_or_completed.empty?
			old_reservations_or_custom_venues(user_business, page)
		elsif date.empty? && !public_or_private.empty? && !current_or_completed.empty?
			old_reservations_or_custom_venues_with_private_or_public(user_business, public_or_private, page)
    	elsif public_or_private.empty? && !date.empty?
			searchWithReservationOrVenue(user_business, date, page)
    	elsif !public_or_private.empty? && !date.empty?
    		searchWithReservationOrVenueAndPublicOrPrivate(user_business, date, public_or_private, page)
    	end		
    end
    def self.searchWithReservationOrVenueAndPublicOrPrivate(user_business, date, public_or_private, page)
      gs = get_games(user_business)
      if user_business.instance_of? Business
          gs.includes(:reservation).references(:reservation)
          .where('reservations.id IS NOT NULL AND reservations.date = ?', date)
          .where('games.public = ?', public_or_private)
          .order("reservations.date asc")
          .paginate(page: page, per_page: 10)
      else
        gs.includes(:reservation, :custom_venue).references(:reservation, :custom_venue)
            .where('reservations.id IS NOT NULL OR custom_venues.id IS NOT NULL')
            .where('reservations.date = ? OR custom_venues.date = ?', date.to_date, date.to_date)
            .where('games.public = ?', public_or_private)
            .order("reservations.date asc", "custom_venues.date asc")
            .paginate(page: page, per_page: 10)
      end
    end

    def self.searchPublicOrPrivateWithReservationOrVenue(user_business, public_or_private, page)
      gs = get_games(user_business)
      if user_business.instance_of? Business
          gs.includes(:reservation).references(:reservation)
          .where('games.public = ?', public_or_private)
          .order("reservations.date asc")
          .paginate(page: page, per_page: 10)
      else
        gs.includes(:reservation, :custom_venue).references(:reservation, :custom_venue)
            .where('reservations.id IS NOT NULL OR custom_venues.id IS NOT NULL')
            .where('reservations.date >= ? OR custom_venues.date >= ?', Date.current, Date.current)
            .where('games.public = ?', public_or_private)
            .order("reservations.date asc", "custom_venues.date asc")
            .paginate(page: page, per_page: 10)
      end
    end

    def self.searchWithReservationOrVenue(user_business, date, page)
      gs = get_games(user_business)
      if user_business.instance_of? Business
          gs.includes(:reservation).references(:reservation)
          .where('reservations.id IS NOT NULL AND reservations.date = ?', date)
          .order("reservations.date asc")
          .paginate(page: page, per_page: 10)
      else
        gs.includes(:reservation, :custom_venue).references(:reservation, :custom_venue)
            .where('reservations.id IS NOT NULL OR custom_venues.id IS NOT NULL')
            .where('reservations.date = ? OR custom_venues.date = ?', date.to_date, date.to_date)
            .order("reservations.date asc", "custom_venues.date asc")
            .paginate(page: page, per_page: 10)
      end
    end

    def self.this_week_games_with_reservation(user_business)
      gs = get_games(user_business)

      gs.includes(:reservation).references(:reservation)
          .where('reservations.id IS NOT NULL AND reservations.date > ? AND reservations.date < ?', Date.current, Date.current + 7.days )
          .order("reservations.date asc")
    end

    def self.this_week_public_games_with_reservation(user_business)
      gs = get_public_games(user_business)

      gs.includes(:reservation).references(:reservation)
          .where('reservations.id IS NOT NULL AND reservations.date > ? AND reservations.date < ?', Date.current, Date.current + 7.days )
          .order("reservations.date asc")
    end

    def self.without_reservation(user_business, page)
        gs = get_games(user_business)
        gs.includes(:reservation, :custom_venue).references(:reservation, :custom_venue)
        .where('reservations.id IS NULL AND custom_venues.id IS NULL')
        .paginate(page: page, per_page: 10)
    end

    def self.old_reservations_or_custom_venues(user_business, page)
       gs = get_games(user_business)

          if user_business.instance_of? Business
              gs.includes(:reservation).references(:reservation)
                .where('reservations.id IS NOT NULL AND reservations.date < ?', Date.current)
                .order("reservations.date desc")
                .paginate(page: page, per_page: 10)
          else
            gs.includes(:reservation, :custom_venue).references(:reservation, :custom_venue)
                .where('reservations.id IS NOT NULL OR custom_venues.id IS NOT NULL')
                .where('reservations.date < ? OR custom_venues.date < ?', Date.current, Date.current)
                .order("reservations.date desc", "custom_venues.date desc")
                .paginate(page: page, per_page: 10)
          end
    end

    def self.old_reservations_or_custom_venues_with_private_or_public(user_business, public_or_private, page)
       gs = get_games(user_business)

          if user_business.instance_of? Business
              gs.includes(:reservation).references(:reservation)
                .where('reservations.id IS NOT NULL AND reservations.date < ?', Date.current)
                .where('games.public = ?', public_or_private)
                .order("reservations.date desc")
                .paginate(page: page, per_page: 10)
          else
            gs.includes(:reservation, :custom_venue).references(:reservation, :custom_venue)
                .where('reservations.id IS NOT NULL OR custom_venues.id IS NOT NULL')
                .where('reservations.date < ? OR custom_venues.date < ?', Date.current, Date.current)
                .where('games.public = ?', public_or_private)
                .order("reservations.date desc", "custom_venues.date desc")
                .paginate(page: page, per_page: 10)
          end
    end

    def self.today_games_with_reservations(user_business)
      gs = get_games(user_business)

      gs.includes(:reservation).references(:reservation)
          .where('reservations.id IS NOT NULL AND reservations.date = ?', Date.current)
          .order("reservations.date asc")
    end

    def self.tomorrow_games_with_reservations(user_business)
      gs = get_games(user_business)

      gs.includes(:reservation).references(:reservation)
          .where('reservations.id IS NOT NULL AND reservations.date = ?', Date.current + 1.days )
          .order("reservations.date asc")
    end

    def self.get_invited_ones(user, page)
      gs = get_invited_games(user)
      gs.includes(:reservation, :custom_venue).references(:reservation, :custom_venue)
      .where('reservations.date <= ? OR custom_venues.date <= ? OR 
      			(reservations.id IS NULL AND custom_venues.id IS NULL)', 
      			Date.current, Date.current)
      .paginate(page: page, per_page: 10)	
    end

    def self.get_invited_ones_with_res(user)
      gs = get_invited_games(user)
      gs.includes(:reservation).references(:reservation)
              .where('reservations.id IS NOT NULL')
              .order("reservations.date asc")
    end
    def self.get_invited_ones_without_res(user)
      gs = get_invited_games(user)
      gs.includes(:reservation).references(:reservation)
              .where('reservations.id IS NULL')
              .order("reservations.date asc")
    end


    def players_confirmed 
      self.game_lines.where(accepted: "Accepted")
    end

    def players_invited
      self.game_lines.where(accepted: "Pending")
    end

    def is_player_involved?(user)
      gl = self.game_lines.where(user_id: user.id)
      if gl.empty?
        return false
      else
          if gl.first.accepted == "Requested"
            return false
          end
      end
      return true
    end

    def set_defaults
      if self.title.nil?
        self.title = 'New Game'
      end

      if self.description.nil?
      self.description = "Enjoy your game! Your are welcome to change this 
                            descrition and let the other players what's up."  
      end
    end

    def self.upcoming_game(user_business)
      gs = get_games(user_business)

      gs.includes(:reservation).references(:reservation)
          .where('reservations.id IS NOT NULL AND reservations.date >= ?', Date.current)
          .order("reservations.date asc").first
    end

    def get_date
      self.get_venue.date
    end

    def get_time
      self.get_venue.time 
    end

    def get_end_time
      self.get_venue.end_time 
    end

    def get_venue
      if self.reservation
        self.reservation
      elsif self.custom_venue
        self.custom_venue
      end  
    end

    private

      def randomize_id
        begin
          self.id = SecureRandom.random_number(1_000_000)
        end while Game.where(id: self.id).exists?
      end

      def self.get_games(u_biz)
        if u_biz.instance_of? Business
          gs = u_biz.games
        else
          gs = Game.joins(game_lines: :user).where(game_lines: {user_id: u_biz.id, accepted: "Accepted" })
        end
        return gs
      end

       def self.get_public_games(u_biz)
        if u_biz.instance_of? Business
          gs = u_biz.games.where(public: true)
        else
          gs = Game.joins(game_lines: :user).where(game_lines: {user_id: u_biz.id, accepted: "Accepted" }, public: true)
        end
        return gs
      end

      def self.get_invited_games(user)
        return Game.joins(game_lines: :user).where(game_lines: {user_id: user.id, accepted: "Pending" }) 
      end
    

end
