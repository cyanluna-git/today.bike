class CreateServicePhotos < ActiveRecord::Migration[8.1]
  def change
    create_table :service_photos do |t|
      t.references :service_order, null: false, foreign_key: true
      t.string :photo_type, null: false, default: "before"
      t.text :caption
      t.datetime :taken_at

      t.timestamps
    end

    add_index :service_photos, :photo_type
  end
end
