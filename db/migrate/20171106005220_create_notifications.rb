class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :recipientable_id
      t.string :recipientable_type
      t.integer :actorable_id
      t.string :actorable_type
      t.datetime :read_at
      t.string :action
      t.integer :notifiable_id
      t.string :notifiable_type

      t.timestamps null: false
    end
  end
end
