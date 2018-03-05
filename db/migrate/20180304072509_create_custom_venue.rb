class CreateCustomVenue < ActiveRecord::Migration[5.1]
  def change
    create_table :custom_venues do |t|
      t.integer	:number_players
      t.string	:ground
      t.string	:field_type
      t.string 	:address 
      t.string 	:city 
      t.string 	:state 
      t.string 	:zipcode 
      t.date 	:date
      t.time 	:time
      t.time 	:end_time
      t.integer :game_id
    end
    add_index :custom_venues, :game_id
    add_index :custom_venues, [:date, :time]
  end
end
