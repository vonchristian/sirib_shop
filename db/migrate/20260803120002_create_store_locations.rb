class CreateStoreLocations < ActiveRecord::Migration[8.1]
  def change
    create_table :store_locations do |t|
      t.references :business, null: false, foreign_key: true
      t.string :name, null: false
      t.string :code, null: false
      t.integer :location_type, null: false, default: 0
      t.boolean :is_main, null: false, default: false
      t.string :address
      t.integer :status, null: false, default: 0
      t.timestamps
    end

    add_index :store_locations, [:business_id, :code], unique: true
    add_index :store_locations, :business_id, where: "is_main = true AND status = 0",
              unique: true, name: "index_store_locations_on_business_active_main"
  end
end
