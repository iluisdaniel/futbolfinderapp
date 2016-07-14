class RemoveUsernameFromBusinesses < ActiveRecord::Migration
  def change
    remove_column :businesses, :username, :string
  end
end
