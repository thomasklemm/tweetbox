class AddCounterCachesToTweets < ActiveRecord::Migration
  def change
    add_column :tweets, :replies_count,  :integer, default: 0
    add_column :tweets, :comments_count, :integer, default: 0
    add_column :tweets, :events_count,   :integer, default: 0
  end
end
