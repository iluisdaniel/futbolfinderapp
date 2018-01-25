class AddAvatarToBusinesses < ActiveRecord::Migration
  def self.up
      add_attachment :businesses, :avatar
    end

    def self.down
      remove_attachment :businesses, :avatar
    end
end
