class CreateTwitterAccounts < ActiveRecord::Migration
  def change
    create_table :twitter_accounts do |t|
      t.belongs_to :project, null: false
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

      t.text :access_scope

      t.integer :max_mentions_timeline_twitter_id, limit: 8
      t.integer :max_user_timeline_twitter_id, limit: 8
      t.integer :max_direct_messages_sent_twitter_id, limit: 8
      t.integer :max_direct_messages_received_twitter_id, limit: 8

      t.timestamps
    end
    add_index :twitter_accounts, :project_id
    add_index :twitter_accounts, [:project_id, :twitter_id]
    add_index :twitter_accounts, [:project_id, :access_scope]

    # Each twitter account may be added only once globally
    add_index :twitter_accounts, :twitter_id, unique: true
  end
end
