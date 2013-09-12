class AddResolutionFieldsToTweets < ActiveRecord::Migration
  def change
    add_column :tweets, :resolved_at, :datetime
    add_column :tweets, :replied_to, :boolean, default: false
  end
end
