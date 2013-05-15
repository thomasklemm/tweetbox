class CreatePlans < ActiveRecord::Migration
  def change
    create_table :plans do |t|
      t.text :name
      t.integer :price, null: false, default: 0
      t.integer :user_limit, null: false
      t.boolean :trial, null: false, default: false

      t.timestamps
    end
  end
end
