class CreateFrameChanges < ActiveRecord::Migration[8.1]
  def change
    create_table :frame_changes do |t|
      t.references :service_order, null: false, foreign_key: true
      t.string :old_frame_brand
      t.string :old_frame_model
      t.string :new_frame_brand, null: false
      t.string :new_frame_model, null: false
      t.string :new_frame_size
      t.text :transferred_parts
      t.text :reason
      t.decimal :cost, precision: 10, scale: 0

      t.timestamps
    end
  end
end
