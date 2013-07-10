class ChangeTweetsConstraints < ActiveRecord::Migration
  def up
    change_column :tweets, :twitter_account_id, :integer, null: true
  end

  def down
    change_column :tweets, :twitter_account_id, :integer, null: false
  end
end
