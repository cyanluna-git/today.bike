class AddConversionFieldsToServiceInquiries < ActiveRecord::Migration[8.1]
  def change
    change_table :service_inquiries do |t|
      t.references :customer, foreign_key: true
      t.references :bicycle, foreign_key: true
      t.references :service_order, foreign_key: true
      t.string :conversion_status, null: false, default: "unlinked"
    end

    add_index :service_inquiries, :conversion_status
  end
end
