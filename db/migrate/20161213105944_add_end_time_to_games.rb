class AddEndTimeToGames < ActiveRecord::Migration
  def change
    add_column :games, :end_time, :time
  end
end
