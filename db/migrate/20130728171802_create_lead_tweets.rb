class CreateLeadTweets < ActiveRecord::Migration
  def change
    create_table :lead_tweets do |t|
      t.integer :twitter_id, limit: 8

      t.text :text

      t.integer :in_reply_to_user_id, limit: 8
      t.integer :in_reply_to_status_id, limit: 8

      t.text :source
      t.text :lang

      t.integer :favorite_count, default: 0
      t.integer :retweet_count, default: 0

      t.integer :lead_id

      t.timestamps
    end

    add_index :lead_tweets, :twitter_id, unique: true
    add_index :lead_tweets, :lead_id
  end
end
