class RemoveActivitiesCountFromTweets < ActiveRecord::Migration
  def change
    remove_column :tweets, :activities_count
  end
end
