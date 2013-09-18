class RenameInvitationCodeToToken < ActiveRecord::Migration
  def change
    rename_column :invitations, :code, :token
  end
end
