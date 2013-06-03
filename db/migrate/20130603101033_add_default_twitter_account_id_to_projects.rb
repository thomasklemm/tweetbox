class AddDefaultTwitterAccountIdToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :default_twitter_account_id, :integer
  end
end
