class AddCustomerInfoToCharges < ActiveRecord::Migration[5.1]
  def change
    add_column :charges, :application_fee, :integer
    add_reference :charges, :user, foreign_key: true, type: :integer
    add_reference :charges, :reservation, foreign_key: true, type: :integer
    add_column :charges, :status, :string
    add_column :charges, :name, :string
    add_column :charges, :email, :string
  end
end