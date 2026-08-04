class CreateServiceAssetValues < ActiveRecord::Migration[8.1]
  def change
    create_table :service_asset_values do |t|
      t.references :service_asset, null: false, foreign_key: true
      t.references :service_asset_field, null: false, foreign_key: true
      t.string :text_value
      t.bigint :integer_value
      t.decimal :decimal_value, precision: 12, scale: 2
      t.date :date_value
      t.boolean :boolean_value
      t.timestamps
    end

    add_index :service_asset_values, [:service_asset_id, :service_asset_field_id], unique: true, name: "index_sav_on_asset_and_field"
  end
end
