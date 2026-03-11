class CreateBicycles < ActiveRecord::Migration[8.1]
  def change
    create_table :bicycles do |t|
      t.string :brand, null: false
      t.string :model_label, null: false
      t.integer :year
      t.string :frame_number
      t.string :bike_type, null: false, default: "road"
      t.string :color
      t.string :status, null: false, default: "active"
      t.references :customer, null: false, foreign_key: true

      t.timestamps
    end

    add_index :bicycles, :frame_number, unique: true
  end
end
