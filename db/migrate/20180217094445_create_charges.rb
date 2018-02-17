class CreateCharges < ActiveRecord::Migration[5.1]
  def change
    create_table :charges do |t|
      t.references :business, foreign_key: true, type: :integer
      t.string :stripe_id
      t.integer :amount
      t.string :card_brand
      t.string :card_last4
      t.string :card_exp_month
      t.string :card_exp_year

      t.timestamps
    end
  end
end
