class ChangeDateTypeForAccepted < ActiveRecord::Migration
  def change
  	change_column :game_lines, :accepted, :string
  end
end
