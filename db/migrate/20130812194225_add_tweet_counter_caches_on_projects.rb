class AddTweetCounterCachesOnProjects < ActiveRecord::Migration
  def change
    add_column :projects, :tweets_count, :integer, default: 0, null: false
    add_column :projects, :incoming_tweets_count, :integer, default: 0, null: false
    add_column :projects, :resolved_tweets_count, :integer, default: 0, null: false
    add_column :projects, :posted_tweets_count, :integer, default: 0, null: false

    p Tweet.counter_culture_fix_counts
  end
end
