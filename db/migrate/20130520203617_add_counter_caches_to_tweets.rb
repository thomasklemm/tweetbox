class AddCounterCachesToTweets < ActiveRecord::Migration
  def change
    add_column :tweets, :transitions_count, :integer, default: 0
    add_column :tweets, :replies_count,     :integer, default: 0
    add_column :tweets, :comments_count,    :integer, default: 0
    add_column :tweets, :retweets_count,    :integer, default: 0
    add_column :tweets, :favorites_count,   :integer, default: 0
    add_column :tweets, :custom_events_count, :integer, default: 0
  end
end
