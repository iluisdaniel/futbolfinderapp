class CreateFields < ActiveRecord::Migration
  def change
    create_table :fields do |t|
      t.integer :number_players
      t.string :name
      t.string :description
      t.decimal :price
      t.integer :business_id

      t.timestamps null: false
    end
    add_index :fields, [:business_id]
  end
end
