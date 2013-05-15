class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.belongs_to :account
      t.text :name

      t.timestamps
    end
    add_index :projects, :account_id
  end
end
