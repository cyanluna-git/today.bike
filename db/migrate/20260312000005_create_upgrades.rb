class CreateUpgrades < ActiveRecord::Migration[8.1]
  def change
    create_table :upgrades do |t|
      t.references :service_order, null: false, foreign_key: true
      t.string :component, null: false
      t.string :before_brand
      t.string :before_model
      t.string :after_brand, null: false
      t.string :after_model, null: false
      t.string :upgrade_purpose, null: false, default: "other"
      t.decimal :cost, precision: 10, scale: 0

      t.timestamps
    end

    add_index :upgrades, :component
    add_index :upgrades, :upgrade_purpose
  end
end
