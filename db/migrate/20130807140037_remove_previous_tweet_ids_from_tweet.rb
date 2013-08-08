class RemovePreviousTweetIdsFromTweet < ActiveRecord::Migration
  def up
    remove_column :tweets, :previous_tweet_ids
  end

  def down
    raise ActiveRecord::IrreversibleMigration, 'one way only'
  end
end
