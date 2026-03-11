class CreateServiceOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :service_orders do |t|
      t.string :order_number, null: false
      t.references :bicycle, null: false, foreign_key: true
      t.string :service_type, null: false
      t.string :status, null: false, default: "received"
      t.datetime :received_at, null: false
      t.date :expected_completion
      t.datetime :completed_at
      t.datetime :delivered_at
      t.text :diagnosis_note
      t.text :work_note
      t.decimal :estimated_cost, precision: 10, scale: 0
      t.decimal :final_cost, precision: 10, scale: 0

      t.timestamps
    end

    add_index :service_orders, :order_number, unique: true
    add_index :service_orders, :status
    add_index :service_orders, :service_type
  end
end
