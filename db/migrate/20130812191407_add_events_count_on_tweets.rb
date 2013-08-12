class AddEventsCountOnTweets < ActiveRecord::Migration
  def change
    add_column :tweets, :events_count, :integer, default: 0

    Tweet.pluck(:id).each { |id| Tweet.reset_counters(id, :events) }
  end
end
