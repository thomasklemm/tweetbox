class CreateInvitationsProjects < ActiveRecord::Migration
  def change
    create_table :invitations_projects do |t|
      t.integer :invitation_id, null: false
      t.integer :project_id, null: false
    end

    add_index :invitations_projects, [:invitation_id, :project_id], unique: true
  end
end
