class Game < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :business, optional: true

  #BUG: it doesnt work for users. only for businesses for some reason.
  before_create :randomize_id
  before_save :set_defaults, if: :new_record?

  has_one :reservation, :dependent => :destroy
  
  has_many :game_lines, dependent: :destroy
  has_many :comments, as: :commentable

  validates :description, length: { maximum: 500, minimum: 6 }, allow_blank: true
  validates :title, length: { minimum: 4, maximum: 60}, allow_blank: true
  validates :number_players, presence: true, numericality: {only_integer: true}
  validates :public, presence: true, length: {minimum:3, maximum:20}

  #validate public 
  validate :check_invite_allowed_presence
  

    ####### validate public presence

    def check_invite_allowed_presence
      errors.add(:invite_allowed, " should present") unless !invite_allowed.nil?
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
          .where('reservations.id IS NOT NULL AND reservations.date > ? AND reservations.date < ?', Date.today, Date.today + 7.days )
          .order("reservations.date asc")
    end

    def self.this_week_public_games_with_reservation(user_business)
      gs = get_public_games(user_business)

      gs.includes(:reservation).references(:reservation)
          .where('reservations.id IS NOT NULL AND reservations.date > ? AND reservations.date < ?', Date.today, Date.today + 7.days )
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
          .where('reservations.id IS NOT NULL AND reservations.date >= ?', Date.today)
          .order("reservations.date asc").first
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
