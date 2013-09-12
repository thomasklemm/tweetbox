class RenameEventsCountToActivitiesCountOnTweets < ActiveRecord::Migration
  def change
    rename_column :tweets, :events_count, :activities_count
  end
end
