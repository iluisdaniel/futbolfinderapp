class ChangeDataTypeForOpenCloseTime < ActiveRecord::Migration[5.1]
  def change
  	change_column :schedules, :open_time, :string
  	change_column :schedules, :close_time, :string
  end
end
