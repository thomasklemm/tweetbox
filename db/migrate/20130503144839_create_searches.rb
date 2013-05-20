class CreateSearches < ActiveRecord::Migration
  def change
    create_table :searches do |t|
      t.belongs_to :twitter_account, null: false
      t.belongs_to :project, null: false

      t.text :query, null: false
      t.boolean :active, default: true
      t.integer :max_tweet_id, limit: 8

      t.timestamps
    end

    add_index :searches, :project_id
    add_index :searches, :twitter_account_id
    add_index :searches, [:project_id, :twitter_account_id]
  end
end
