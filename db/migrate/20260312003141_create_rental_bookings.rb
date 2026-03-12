class CreateRentalBookings < ActiveRecord::Migration[8.1]
  def change
    create_table :rental_bookings do |t|
      t.references :rental, null: false, foreign_key: true
      t.references :customer, foreign_key: true
      t.string :guest_name
      t.string :guest_phone
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.string :status, null: false, default: "pending"
      t.decimal :total_amount, precision: 10, scale: 0
      t.text :notes

      t.timestamps
    end

    add_index :rental_bookings, :status
    add_index :rental_bookings, [:start_date, :end_date]
  end
end
