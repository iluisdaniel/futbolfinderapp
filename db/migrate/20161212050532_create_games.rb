class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.date :date
      t.time :time
      t.references :user, index: true, foreign_key: true
      t.references :business, index: true, foreign_key: true
      t.integer :field_id

      t.timestamps null: false
    end
  end
end
