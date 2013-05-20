class CreateRetweets < ActiveRecord::Migration
  def change
    create_table :retweets do |t|
      t.belongs_to :tweet, null: false
      t.belongs_to :user, null: false
      t.belongs_to :project, null: false

      t.belongs_to :twitter_account, null: false
      t.datetime :posted_at

      t.timestamps
    end

    add_index :retweets, :tweet_id
    add_index :retweets, :user_id
    add_index :retweets, :project_id
  end
end
