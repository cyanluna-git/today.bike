class CreateNotifications < ActiveRecord::Migration[8.1]
  def change
    create_table :notifications do |t|
      t.references :customer, null: false, foreign_key: true
      t.references :service_order, null: true, foreign_key: true
      t.string :notification_type, null: false
      t.string :channel, null: false, default: "kakao"
      t.string :status, null: false, default: "pending"
      t.text :message
      t.datetime :sent_at
      t.text :error_message

      t.timestamps
    end

    add_index :notifications, :notification_type
    add_index :notifications, :status
  end
end
