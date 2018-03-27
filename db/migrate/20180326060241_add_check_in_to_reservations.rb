class AddCheckInToReservations < ActiveRecord::Migration[5.1]
  def change
    add_column :reservations, :check_in_time, :datetime
  end
end
