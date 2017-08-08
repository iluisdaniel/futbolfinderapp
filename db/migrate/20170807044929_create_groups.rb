class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :title
      t.string :about
      t.integer :user_id

      t.timestamps null: false
    end
    add_index :groups, [:user_id]
  end
end
