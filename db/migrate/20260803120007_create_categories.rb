class CreateCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :categories do |t|
      t.references :business, null: false, foreign_key: true
      t.references :parent, foreign_key: { to_table: :categories }
      t.string :name, null: false
      t.string :code
      t.integer :status, null: false, default: 0
      t.timestamps
    end

    add_index :categories, [:business_id, :code], unique: true
  end
end
