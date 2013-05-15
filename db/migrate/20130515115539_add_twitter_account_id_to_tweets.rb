class AddTwitterAccountIdToTweets < ActiveRecord::Migration
  def change
    add_column :tweets, :twitter_account_id, :integer
  end
end
