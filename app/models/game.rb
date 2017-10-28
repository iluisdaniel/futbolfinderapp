class Game < ActiveRecord::Base
  belongs_to :user
  belongs_to :business

  has_one :reservation, :dependent => :destroy
  
  has_many :game_lines, dependent: :destroy
  has_many :comments, as: :commentable

  validates :description, length: { maximum: 500, minimum: 5 }, allow_blank: false
  validates :title, length: { minimum: 5, maximum: 60}, allow_blank: false
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
          .where('reservations.id IS NOT NULL AND reservations.date > ?', Time.now)
          .order("reservations.date asc")
    end

    def self.without_reservation(user_business)
        gs = get_games(user_business)
        gs.includes(:reservation).references(:reservation).where('reservations.id IS NULL')
    end

    def self.old_reservations(user_business)
       gs = get_games(user_business)

      gs.includes(:reservation).references(:reservation)
          .where('reservations.id IS NOT NULL AND reservations.date < ?', Time.now)
          .order("reservations.date desc")
    end

    def players_confirmed 
      self.game_lines.where(accepted: true)
    end

    def players_invited
      self.game_lines.where(accepted: false)
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
