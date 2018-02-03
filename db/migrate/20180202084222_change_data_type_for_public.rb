class ChangeDataTypeForPublic < ActiveRecord::Migration
  def change
  	change_column :games, :public, :string
  end
end
