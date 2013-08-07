class CreateConversations < ActiveRecord::Migration
  def change
    create_table :conversations do |t|
      t.belongs_to :previous_tweet, index: true
      t.belongs_to :future_tweet, index: true

      t.timestamps
    end

    add_index :conversations, [:previous_tweet_id, :future_tweet_id], unique: true
  end
end
