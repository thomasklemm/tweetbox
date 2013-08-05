class RenameAdminFlagToStaffMemberOnUsers < ActiveRecord::Migration
  def change
    rename_column :users, :admin, :staff_member
  end
end
