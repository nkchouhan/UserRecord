class CreateUserRecords < ActiveRecord::Migration
  def change
    create_table :user_records do |t|
      t.string :business_name
      t.string :phone_number
      t.text   :url
      t.timestamps
    end
  end
end
