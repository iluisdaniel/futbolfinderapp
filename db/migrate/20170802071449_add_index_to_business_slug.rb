class AddIndexToBusinessSlug < ActiveRecord::Migration
  def change
  	add_index :businesses, :slug, unique: true
  end
end
