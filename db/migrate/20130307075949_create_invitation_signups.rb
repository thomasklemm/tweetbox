class CreateInvitationSignups < ActiveRecord::Migration
  def change
    create_table :invitation_signups do |t|

      t.timestamps
    end
  end
end
