class AddPushedAtToTweets < ActiveRecord::Migration
  def change
    add_column :tweets, :pushed, :boolean, default: false
  end
end
