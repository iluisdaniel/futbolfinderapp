class AddInvitedByToGameLine < ActiveRecord::Migration
  def change
    add_column :game_lines, :invited_by, :integer
  end
end
