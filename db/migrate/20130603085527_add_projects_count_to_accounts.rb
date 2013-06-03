class AddProjectsCountToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :projects_count, :integer
  end
end
