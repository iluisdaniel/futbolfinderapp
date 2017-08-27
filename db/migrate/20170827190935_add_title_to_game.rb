class AddTitleToGame < ActiveRecord::Migration
  def change
    add_column :games, :title, :string
    add_column :games, :description, :text
    add_column :games, :public, :boolean
  end
end
