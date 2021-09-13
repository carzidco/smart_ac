class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.string  :serial_number
      t.datetime :created_at
      t.string :firmware_version
      t.integer :user_id
    end
  end
end
