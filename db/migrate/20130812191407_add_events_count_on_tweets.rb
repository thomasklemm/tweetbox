class AddEventsCountOnTweets < ActiveRecord::Migration
  def change
    add_column :tweets, :events_count, :integer, default: 0
  end
end
