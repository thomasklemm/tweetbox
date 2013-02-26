class AddTrialExpiresAtToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :trial_expires_at, :datetime
    add_index :accounts, :trial_expires_at
  end
end
