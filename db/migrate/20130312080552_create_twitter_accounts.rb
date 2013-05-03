class CreateTwitterAccounts < ActiveRecord::Migration
  def change
    create_table :twitter_accounts do |t|
      t.belongs_to :project
      t.string :uid
      t.string :token
      t.string :token_secret
      t.integer :twitter_id, limit: 8
      t.string :name
      t.string :screen_name
      t.string :location
      t.string :description
      t.string :url
      t.string :profile_image_url

      t.boolean :get_mentions, default: true
      t.integer :max_mentions_tweet_id, limit: 8
      t.boolean :get_home, default: true
      t.integer :max_home_tweet_id, limit: 8

      t.timestamps
    end

    add_index :twitter_accounts, :project_id
    add_index :twitter_accounts, [:project_id, :uid], unique: true
    add_index :twitter_accounts, :twitter_id, unique: true # REVIEW: What's the difference between :uid and :twitter_id
  end
end
