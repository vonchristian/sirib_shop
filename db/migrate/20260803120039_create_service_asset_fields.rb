class CreateServiceAssetFields < ActiveRecord::Migration[8.1]
  def change
    create_table :service_asset_fields do |t|
      t.references :service_asset_category, null: false, foreign_key: true
      t.string :name, null: false
      t.string :label, null: false
      t.integer :data_type, null: false, default: 0
      t.boolean :required, null: false, default: false
      t.boolean :unique, null: false, default: false
      t.integer :position, null: false, default: 0
      t.boolean :active, null: false, default: true
      t.timestamps
    end

    add_index :service_asset_fields, [:service_asset_category_id, :name], unique: true
    add_index :service_asset_fields, [:service_asset_category_id, :position]
  end
end
