class AddNumberOfPlayersToGames < ActiveRecord::Migration
  def change
    add_column :games, :number_players, :int
  end
end
