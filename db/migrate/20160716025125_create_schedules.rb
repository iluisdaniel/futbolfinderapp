class CreateSchedules < ActiveRecord::Migration
  def change
    create_table :schedules do |t|
      t.string :day
      t.time :open_time
      t.time :close_time
      t.integer :business_id

      t.timestamps null: false
    end
    add_index :schedules, [:business_id]
  end
end
