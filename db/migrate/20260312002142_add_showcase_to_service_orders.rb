class AddShowcaseToServiceOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :service_orders, :showcase, :boolean, default: false
  end
end
