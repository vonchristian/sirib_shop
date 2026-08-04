class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.references :business, null: false, foreign_key: true
      t.references :category, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.string :brand
      t.integer :status, null: false, default: 0
      t.timestamps
    end

    add_index :products, [:business_id, :name]
  end
end
