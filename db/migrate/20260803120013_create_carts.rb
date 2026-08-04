class CreateCarts < ActiveRecord::Migration[8.1]
  def change
    create_table :carts do |t|
      t.references :business, null: false, foreign_key: true
      t.references :store_location, null: false, foreign_key: true
      t.references :customer, foreign_key: true
      t.integer :status, null: false, default: 0
      t.references :created_by_user, foreign_key: { to_table: :users }
      t.timestamps
    end

    add_index :carts, [:store_location_id, :status]
  end
end
