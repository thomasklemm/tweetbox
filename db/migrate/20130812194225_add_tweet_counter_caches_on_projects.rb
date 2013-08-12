class AddTweetCounterCachesOnProjects < ActiveRecord::Migration
  def change
    add_column :projects, :tweets_count, :integer, default: 0, null: false
    add_column :projects, :incoming_tweets_count, :integer, default: 0, null: false
    add_column :projects, :resolved_tweets_count, :integer, default: 0, null: false
    add_column :projects, :posted_tweets_count, :integer, default: 0, null: false

    Project.find_each do |project|
      project.update tweets_count: project.tweets.count,
                     incoming_tweets_count: project.incoming_tweets.count,
                     resolved_tweets_count: project.resolved_tweets.count,
                     posted_tweets_count: project.posted_tweets.count
    end
  end
end
