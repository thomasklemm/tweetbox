class CreatePermissions < ActiveRecord::Migration
  def change
    create_table :permissions do |t|
      t.belongs_to :membership
      t.belongs_to :project
      t.belongs_to :user

      t.timestamps
    end
    add_index :permissions, [:user_id, :project_id]
    add_index :permissions, [:membership_id, :project_id],
      name: 'index_permissions_on_membership_and_project', unique: true
  end
end
