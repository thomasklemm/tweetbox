class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.belongs_to :account, null: false

      t.text :name, null: false

      t.timestamps
    end

    add_index :projects, :account_id
  end
end
