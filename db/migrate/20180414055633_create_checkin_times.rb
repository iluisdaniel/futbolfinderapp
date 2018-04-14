class CreateCheckinTimes < ActiveRecord::Migration[5.1]
  def change
    create_table :checkin_times do |t|
     	t.references :reservation, index: true, foreign_key: true, type: :integer
     	t.timestamps
    end
  end
end
