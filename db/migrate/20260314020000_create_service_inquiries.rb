class CreateServiceInquiries < ActiveRecord::Migration[8.1]
  def change
    create_table :service_inquiries do |t|
      t.string :name, null: false
      t.string :phone, null: false
      t.string :email
      t.text :message, null: false
      t.date :desired_visit_on
      t.string :status, null: false, default: "pending"
      t.string :request_category, null: false, default: "general"
      t.string :source_page
      t.string :service_type
      t.references :product, foreign_key: true
      t.text :admin_notes
      t.datetime :responded_at

      t.timestamps
    end

    add_index :service_inquiries, :status
    add_index :service_inquiries, :request_category
    add_index :service_inquiries, :service_type
  end
end
