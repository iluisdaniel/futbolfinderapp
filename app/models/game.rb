class Game < ActiveRecord::Base
  belongs_to :user
  belongs_to :business

  #BUG: it doesnt work for users. only for businesses for some reason.
  before_save :set_defaults, if: :new_record?

  has_one :reservation, :dependent => :destroy
  
  has_many :game_lines, dependent: :destroy
  has_many :comments, as: :commentable

  validates :description, length: { maximum: 500, minimum: 6 }, allow_blank: true
  validates :title, length: { minimum: 4, maximum: 60}, allow_blank: true
  validates :number_players, presence: true, numericality: {only_integer: true}

  #validate public 
  validate :check_public_is_presence

    ####### validate public presence
    def check_public_is_presence
      errors.add(:public, " should be presence") unless !public.nil?
    end

    def self.with_reservation(user_business)
      gs = get_games(user_business)

      gs.includes(:reservation).references(:reservation)
          .where('reservations.id IS NOT NULL AND reservations.date >= ?', Date.today)
          .order("reservations.date asc")
    end

    def self.this_week_games_with_reservation(user_business)
      gs = get_games(user_business)

      gs.includes(:reservation).references(:reservation)
          .where('reservations.id IS NOT NULL AND reservations.date > ? AND reservations.date < ?', Date.tomorrow, Date.today + 7.days )
          .order("reservations.date asc")
    end

    def self.without_reservation(user_business)
        gs = get_games(user_business)
        gs.includes(:reservation).references(:reservation).where('reservations.id IS NULL')
    end

    def self.old_reservations(user_business)
       gs = get_games(user_business)

      gs.includes(:reservation).references(:reservation)
          .where('reservations.id IS NOT NULL AND reservations.date < ?', Date.today)
          .order("reservations.date desc")
    end

    def self.today_games_with_reservations(user_business)
      gs = get_games(user_business)

      gs.includes(:reservation).references(:reservation)
          .where('reservations.id IS NOT NULL AND reservations.date = ?', Date.today)
          .order("reservations.date asc")
    end

    def self.tomorrow_games_with_reservations(user_business)
      gs = get_games(user_business)

      gs.includes(:reservation).references(:reservation)
          .where('reservations.id IS NOT NULL AND reservations.date = ?', Date.today + 1.days )
          .order("reservations.date asc")
    end

    def players_confirmed 
      self.game_lines.where(accepted: true)
    end

    def players_invited
      self.game_lines.where(accepted: false)
    end

    def is_player_involved?(user)
      if self.game_lines.where(user_id: user.id).empty?
        return false
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

    private

      def self.get_games(u_biz)
        if u_biz.instance_of? Business
          gs = u_biz.games
        else
          gs = Game.joins(game_lines: :user).where(game_lines: {user_id: u_biz.id})
        end
        return gs
      end
    

end
