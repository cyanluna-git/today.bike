class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.text :description
      t.string :category, null: false, default: "other"
      t.string :brand
      t.decimal :price, precision: 10, scale: 0, null: false
      t.decimal :sale_price, precision: 10, scale: 0
      t.integer :stock_quantity, default: 0
      t.boolean :active, default: true
      t.string :sku

      t.timestamps
    end

    add_index :products, :category
    add_index :products, :active
    add_index :products, :sku, unique: true
  end
end
