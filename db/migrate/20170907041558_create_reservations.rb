class CreateReservations < ActiveRecord::Migration
  #Should add status, notes, and maybe reason of cancellation
  def change
    create_table :reservations do |t|
      t.date :date
      t.time :time
      t.time :end_time
      t.integer :business_id
      t.integer :field_id
      t.integer :game_id

      t.timestamps null: false
    end
     add_index :reservations, [:game_id, :business_id, :field_id]
  end
end
