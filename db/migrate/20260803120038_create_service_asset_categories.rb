class CreateServiceAssetCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :service_asset_categories do |t|
      t.references :business, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.boolean :active, null: false, default: true
      t.timestamps
    end

    add_index :service_asset_categories, [:business_id, :name], unique: true
  end
end
