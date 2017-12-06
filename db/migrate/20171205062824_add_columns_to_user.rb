class AddColumnsToUser < ActiveRecord::Migration
  def change
    add_column :users, :location, :string
    add_column :users, :slug, :string
    add_column :users, :games_played, :integer
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :gender, :string
    add_column :users, :dob, :date
    add_column :users, :phone, :string
    add_index :users, :slug
    add_index :users, :phone
  end
end
