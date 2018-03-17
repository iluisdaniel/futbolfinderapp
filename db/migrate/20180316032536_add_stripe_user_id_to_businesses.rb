class AddStripeUserIdToBusinesses < ActiveRecord::Migration[5.1]
  def change
    add_column :businesses, :stripe_user_id, :string
  end
end
