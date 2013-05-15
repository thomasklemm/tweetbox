class CreateTwitterAccounts < ActiveRecord::Migration
  def change
    create_table :twitter_accounts do |t|
      t.belongs_to :project

      t.text :uid, null: false
      t.text :token, null: false
      t.text :token_secret, null: false

      t.integer :twitter_id, limit: 8, null: false
      t.text :name
      t.text :screen_name
      t.text :location
      t.text :description
      t.text :url
      t.text :profile_image_url

      t.boolean :get_mentions, default: true
      t.integer :max_mentions_tweet_id, limit: 8
      t.boolean :get_home, default: true
      t.integer :max_home_tweet_id, limit: 8

      t.text :auth_scope

      t.timestamps
    end

    add_index :twitter_accounts, :project_id
    add_index :twitter_accounts, :twitter_id, unique: true
  end
end
