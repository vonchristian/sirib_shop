class DropLegacyRepairTables < ActiveRecord::Migration[8.1]
  def change
    drop_table :work_order_lines, if_exists: true
    drop_table :repair_devices, if_exists: true
  end
end
