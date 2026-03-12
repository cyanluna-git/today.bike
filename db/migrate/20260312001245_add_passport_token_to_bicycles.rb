class AddPassportTokenToBicycles < ActiveRecord::Migration[8.1]
  def change
    add_column :bicycles, :passport_token, :string
    add_index :bicycles, :passport_token, unique: true
  end
end
