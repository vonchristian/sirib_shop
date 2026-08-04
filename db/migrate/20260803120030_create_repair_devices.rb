class CreateRepairDevices < ActiveRecord::Migration[8.1]
  def change
    create_table :repair_devices do |t|
      t.references :work_order, null: false, foreign_key: true
      t.string :brand
      t.string :model
      t.string :imei_1
      t.string :imei_2
      t.string :serial_number
      t.string :condition
      t.text :customer_notes
      t.text :technician_notes
      t.references :inventory_item, foreign_key: true
      t.timestamps
    end
  end
end
