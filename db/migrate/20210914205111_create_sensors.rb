class CreateSensors < ActiveRecord::Migration
  def change
    create_table :sensors do |t|
      t.string  :temperature
      t.float   :air_humidity_percentage
      t.float   :carbon_monoxide_level
      t.string  :device_health_status
      t.datetime :created_at
      t.integer :device_id
    end
  end
end
