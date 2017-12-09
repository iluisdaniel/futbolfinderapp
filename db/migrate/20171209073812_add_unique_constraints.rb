class AddUniqueConstraints < ActiveRecord::Migration
  def change
  	add_index :reservations, [:date, :time, :end_time, :field_id], unique: true
  end
end
