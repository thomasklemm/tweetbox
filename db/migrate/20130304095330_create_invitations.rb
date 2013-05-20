class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.belongs_to :account, null: false
      t.belongs_to :sender, null: false
      t.belongs_to :invitee

      t.text :code, null: false
      t.text :email, null: false

      t.boolean :admin, default: false
      t.boolean :used, default: false

      t.timestamps
    end
    add_index :invitations, :account_id
    add_index :invitations, :code, unique: true
  end
end
