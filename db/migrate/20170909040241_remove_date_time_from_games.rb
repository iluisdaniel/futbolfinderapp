class RemoveDateTimeFromGames < ActiveRecord::Migration
  def change
  	remove_column :games, :date
  	remove_column :games, :time
  	remove_column :games, :end_time
  	remove_column :games, :field_id
  end
end
