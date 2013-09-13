class RemoveConfirmationFieldsFromUsers < ActiveRecord::Migration
  def up
    remove_index :users, :confirmation_token

    remove_column :users, :confirmation_token
    remove_column :users, :confirmed_at
    remove_column :users, :confirmation_sent_at
    remove_column :users, :unconfirmed_email # Only if using reconfirmable
  end

  def down
    add_column :users, :confirmation_token, :text
    add_column :users, :confirmed_at, :datetime
    add_column :users, :confirmation_sent_at, :datetime
    add_column :users, :unconfirmed_email, :text

    add_index :users, :confirmation_token
  end
end
