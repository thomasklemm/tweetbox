class AddStatusIdToTweets < ActiveRecord::Migration
  def change
    add_column :tweets, :status_id, :integer
    add_index :tweets, :status_id
  end
end
