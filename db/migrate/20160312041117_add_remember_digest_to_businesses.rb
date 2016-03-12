class AddRememberDigestToBusinesses < ActiveRecord::Migration
  def change
    add_column :businesses, :remember_digest, :string
  end
end
