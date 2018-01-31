class ChangeDefaultValueForAccepted < ActiveRecord::Migration
  def change
  	change_column_default(:game_lines, :accepted, nil)
  end
end
