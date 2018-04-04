class AddErrorMessageToCharge < ActiveRecord::Migration[5.1]
  def change
  	add_column :charges, :error_msg, :string
  end
end
