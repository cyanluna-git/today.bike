class CreateCustomers < ActiveRecord::Migration[8.1]
  def change
    create_table :customers do |t|
      t.string :name, null: false
      t.string :phone, null: false
      t.string :email
      t.string :kakao_uid
      t.text :memo
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :customers, :phone, unique: true
  end
end
