class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.text :code, null: false
      t.text :email, null: false
      t.belongs_to :account
      t.belongs_to :sender
      t.belongs_to :invitee
      t.boolean :admin, null: false, default: false
      t.boolean :used, null: false, default: false

      t.timestamps
    end
    add_index :invitations, :account_id
    add_index :invitations, :code, unique: true
  end
end
