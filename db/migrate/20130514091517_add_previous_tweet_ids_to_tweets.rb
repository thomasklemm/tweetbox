class AddPreviousTweetIdsToTweets < ActiveRecord::Migration
  def change
    add_column :tweets, :previous_tweet_ids, :integer, limit: 8, array: true
    add_index :tweets, :previous_tweet_ids, using: :gin
  end
end
