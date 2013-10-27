class AddEventsToTweets < ActiveRecord::Migration
  def change
    add_column :tweets, :events, :text
  end
end
