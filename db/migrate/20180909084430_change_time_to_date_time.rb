class ChangeTimeToDateTime < ActiveRecord::Migration[5.1]
  def up
    change_column :reservations, :time, :datetime
    change_column :reservations, :end_time, :datetime
  end

  def down
    change_column :reservations, :time, :time
    change_column :reservations, :end_time, :time
  end
end
