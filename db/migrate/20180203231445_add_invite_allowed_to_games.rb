class AddInviteAllowedToGames < ActiveRecord::Migration
  def change
    add_column :games, :invite_allowed, :boolean
  end
end
