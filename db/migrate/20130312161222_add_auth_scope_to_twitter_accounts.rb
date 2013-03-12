class AddAuthScopeToTwitterAccounts < ActiveRecord::Migration
  def change
    add_column :twitter_accounts, :auth_scope, :string
  end
end
