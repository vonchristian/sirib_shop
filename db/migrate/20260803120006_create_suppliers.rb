class CreateSuppliers < ActiveRecord::Migration[8.1]
  def change
    create_table :suppliers do |t|
      t.references :business, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :supplier_type, null: false, default: 0
      t.string :code
      t.string :email
      t.string :phone
      t.string :tax_identifier
      t.integer :status, null: false, default: 0
      t.timestamps
    end

    add_index :suppliers, [:business_id, :code], unique: true
  end
end
