class CreatePermissions < ActiveRecord::Migration
  def change
    create_table :permissions do |t|
      t.belongs_to :project, null: false
      t.belongs_to :membership, null: false
      t.belongs_to :user, null: false

      t.timestamps
    end

    add_index :permissions, [:user_id, :project_id]
    add_index :permissions, [:membership_id, :project_id],
      name: 'index_permissions_on_membership_and_project', unique: true
  end
end
