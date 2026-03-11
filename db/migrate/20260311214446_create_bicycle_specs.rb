class CreateBicycleSpecs < ActiveRecord::Migration[8.1]
  def change
    create_table :bicycle_specs do |t|
      t.references :bicycle, null: false, foreign_key: true
      t.string :component, null: false
      t.string :brand, null: false
      t.string :component_model, null: false
      t.text :spec_detail

      t.timestamps
    end

    add_index :bicycle_specs, [ :bicycle_id, :component ]
  end
end
