class AddAcceptedToGameLines < ActiveRecord::Migration
  def change
    add_column :game_lines, :accepted, :boolean, default: false
  end
end
