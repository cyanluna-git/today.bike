class CreateRepairLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :repair_logs do |t|
      t.references :service_order, null: false, foreign_key: true
      t.text :symptom, null: false
      t.text :diagnosis
      t.text :treatment
      t.string :repair_category, null: false
      t.integer :labor_minutes

      t.timestamps
    end

    add_index :repair_logs, :repair_category
  end
end
