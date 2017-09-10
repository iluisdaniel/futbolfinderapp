class Game < ActiveRecord::Base
  belongs_to :user
  belongs_to :business

  has_one :reservation, :dependent => :destroy
  
  has_many :game_lines, dependent: :destroy
  has_many :comments, as: :commentable

  validates :description, length: { maximum: 500, minimum: 5 }, allow_blank: true
  validates :title, length: { minimum: 5, maximum: 60}, allow_blank: true
  validates :number_players, presence: true, numericality: {only_integer: true}

  #validate public 
  validate :check_public_is_presence

    ####### validate public presence
    def check_public_is_presence
      errors.add(:public, " should be presence") unless !public.nil?
    end
    

end
