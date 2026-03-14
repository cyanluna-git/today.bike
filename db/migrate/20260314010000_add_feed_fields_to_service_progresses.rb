class AddFeedFieldsToServiceProgresses < ActiveRecord::Migration[8.1]
  def change
    add_column :service_progresses, :entry_type, :string, null: false, default: "status_change"
    add_column :service_progresses, :title, :string
    add_column :service_progresses, :customer_visible, :boolean, null: false, default: true
    add_column :service_progresses, :work_summary, :text
    add_column :service_progresses, :cost_summary, :text
    add_column :service_progresses, :review_state, :string, null: false, default: "none"

    add_index :service_progresses, :entry_type
    add_index :service_progresses, :customer_visible
    add_index :service_progresses, :review_state
  end
end
