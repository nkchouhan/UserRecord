class AddColumnStatus < ActiveRecord::Migration
  def change
    add_column :user_records, :status, :boolean, default: false
  end
end
