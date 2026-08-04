class CreateCustomers < ActiveRecord::Migration[8.1]
  def change
    create_table :customers do |t|
      t.references :business, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :customer_type, null: false, default: 0
      t.string :code
      t.string :email
      t.string :phone
      t.string :tax_identifier
      t.integer :status, null: false, default: 0
      t.references :parent, foreign_key: { to_table: :customers }
      t.timestamps
    end

    add_index :customers, [:business_id, :code], unique: true
  end
end
