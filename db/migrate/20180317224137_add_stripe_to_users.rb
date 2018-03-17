class AddStripeToUsers < ActiveRecord::Migration[5.1]
  def change
  		add_column :users, :stripe_id, :string
  		add_column :users, :card_brand, :string
  		add_column :users, :card_last4, :string
  		add_column :users, :card_exp_month, :string
  		add_column :users, :card_exp_year, :string
  end
end
