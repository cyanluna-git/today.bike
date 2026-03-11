class CreateFittingRecords < ActiveRecord::Migration[8.1]
  def change
    create_table :fitting_records do |t|
      t.references :bicycle, null: false, foreign_key: true
      t.references :service_order, null: true, foreign_key: true
      t.datetime :recorded_at, null: false

      # Saddle
      t.decimal :saddle_height, precision: 5, scale: 1
      t.decimal :saddle_setback, precision: 5, scale: 1
      t.decimal :saddle_tilt, precision: 5, scale: 1
      t.string :saddle_brand
      t.string :saddle_model

      # Handlebar
      t.decimal :handlebar_width, precision: 5, scale: 1
      t.decimal :handlebar_drop, precision: 5, scale: 1
      t.decimal :handlebar_reach, precision: 5, scale: 1
      t.decimal :handlebar_stack, precision: 5, scale: 1

      # Stem
      t.decimal :stem_length, precision: 5, scale: 1
      t.decimal :stem_angle, precision: 5, scale: 1
      t.decimal :stem_spacer, precision: 5, scale: 1

      # Crank
      t.decimal :crank_length, precision: 5, scale: 1

      # Cleat
      t.text :cleat_left
      t.text :cleat_right

      # Notes
      t.text :notes

      t.timestamps
    end
  end
end
