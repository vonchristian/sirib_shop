class CreateServiceAssets < ActiveRecord::Migration[8.1]
  def change
    create_table :service_assets do |t|
      t.references :business, null: false, foreign_key: true
      t.references :customer, null: false, foreign_key: true
      t.references :service_asset_category, null: false, foreign_key: true
      t.string :name, null: false
      t.timestamps
    end

    add_index :service_assets, [:customer_id, :service_asset_category_id]
    add_index :service_assets, [:business_id, :name]
  end
end
