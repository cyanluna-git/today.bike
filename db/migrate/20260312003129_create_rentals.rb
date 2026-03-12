class CreateRentals < ActiveRecord::Migration[8.1]
  def change
    create_table :rentals do |t|
      t.string :name, null: false
      t.text :description
      t.string :rental_type, null: false, default: "road"
      t.decimal :daily_rate, precision: 10, scale: 0, null: false
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :rentals, :rental_type
    add_index :rentals, :active
  end
end
