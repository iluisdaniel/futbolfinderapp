class CreateGroupLines < ActiveRecord::Migration
  def change
    create_table :group_lines do |t|
      t.references :group, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.boolean :admin, default: false

      t.timestamps null: false
    end
  end
end
