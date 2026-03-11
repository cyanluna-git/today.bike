class CreatePartsReplacements < ActiveRecord::Migration[8.1]
  def change
    create_table :parts_replacements do |t|
      t.references :service_order, null: false, foreign_key: true
      t.string :component, null: false
      t.string :old_brand
      t.string :old_model
      t.string :new_brand, null: false
      t.string :new_model, null: false
      t.text :reason
      t.decimal :cost, precision: 10

      t.timestamps
    end

    add_index :parts_replacements, :component
  end
end
