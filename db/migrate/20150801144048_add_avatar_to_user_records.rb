class AddAvatarToUserRecords < ActiveRecord::Migration
  def change
    add_column :user_records, :avatar, :string
  end
end
