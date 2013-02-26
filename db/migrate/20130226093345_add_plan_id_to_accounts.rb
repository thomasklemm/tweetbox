class AddPlanIdToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :plan_id, :integer
    add_index :accounts, :plan_id
  end
end
