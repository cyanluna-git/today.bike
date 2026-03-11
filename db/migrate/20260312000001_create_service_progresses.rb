class CreateServiceProgresses < ActiveRecord::Migration[8.1]
  def change
    create_table :service_progresses do |t|
      t.references :service_order, null: false, foreign_key: true
      t.string :from_status, null: false
      t.string :to_status, null: false
      t.text :note
      t.datetime :changed_at, null: false

      t.timestamps
    end

    add_index :service_progresses, :changed_at
  end
end
