class CreateCashRegisters < ActiveRecord::Migration[8.1]
  def change
    create_table :cash_registers do |t|
      t.references :business, null: false, foreign_key: true
      t.references :store_location, null: false, foreign_key: true
      t.string :name, null: false
      t.string :code, null: false
      t.integer :status, null: false, default: 0
      t.timestamps
    end

    add_index :cash_registers, [:business_id, :code], unique: true
  end
end
