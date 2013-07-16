class AddImportedAtToTwitterAccounts < ActiveRecord::Migration
  def change
    add_column :twitter_accounts, :imported_at, :datetime
  end
end
