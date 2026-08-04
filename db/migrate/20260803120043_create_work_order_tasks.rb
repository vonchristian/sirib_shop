class CreateWorkOrderTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :work_order_tasks do |t|
      t.references :work_order, null: false, foreign_key: true
      t.references :assigned_user, foreign_key: { to_table: :users }
      t.string :description, null: false
      t.integer :status, null: false, default: 0
      t.integer :estimated_minutes
      t.integer :actual_minutes
      t.datetime :started_at
      t.datetime :completed_at
      t.timestamps
    end

    add_index :work_order_tasks, [:work_order_id, :status]
  end
end
