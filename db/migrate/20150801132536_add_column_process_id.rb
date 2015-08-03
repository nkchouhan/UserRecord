class AddColumnProcessId < ActiveRecord::Migration
  def change
    add_column :user_records, :process_id, :string
  end
end
