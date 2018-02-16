class AddColumnsToBusinesses < ActiveRecord::Migration[5.1]
  def change
  	add_column :businesses, :stripe_id, :string
  	add_column :businesses, :stripe_subscription_id, :string
  	add_column :businesses, :card_brand, :string
  	add_column :businesses, :card_last4, :string
  	add_column :businesses, :card_exp_month, :string
  	add_column :businesses, :card_exp_year, :string
  	add_column :businesses, :expires_at, :datetime
  end
end
