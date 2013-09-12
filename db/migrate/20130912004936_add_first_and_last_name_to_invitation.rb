class AddFirstAndLastNameToInvitation < ActiveRecord::Migration
  def change
    add_column :invitations, :first_name, :text
    add_column :invitations, :last_name, :text

    Invitation.find_each do |invitation|
      parts = invitation.name.split(' ')
      invitation.first_name = parts[0]
      invitation.last_name = parts[1..100].join(' ')
      invitation.save
    end

    remove_column :invitations, :name
  end
end
