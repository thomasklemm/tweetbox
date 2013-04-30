class AddInviteeIdToInvitations < ActiveRecord::Migration
  def change
    add_column :invitations, :invitee_id, :integer
  end
end
