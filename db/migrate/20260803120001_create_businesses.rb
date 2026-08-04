class CreateBusinesses < ActiveRecord::Migration[8.1]
  def change
    create_table :businesses do |t|
      t.string :name, null: false
      t.string :legal_name
      t.string :code, null: false
      t.string :tax_identifier
      t.string :email
      t.string :phone
      t.string :timezone, null: false, default: "Asia/Manila"
      t.string :currency, null: false, default: "PHP"
      t.integer :status, null: false, default: 0
      t.timestamps
    end

    add_index :businesses, :code, unique: true
  end
end
