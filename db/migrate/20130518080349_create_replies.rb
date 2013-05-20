class CreateReplies < ActiveRecord::Migration
  def change
    create_table :replies do |t|
      t.belongs_to :tweet, null: false
      t.belongs_to :user, null: false
      t.belongs_to :project, null: false

      t.belongs_to :twitter_account, null: false
      t.text :text, null: false
      t.datetime :posted_at

      t.timestamps
    end

    add_index :replies, :tweet_id
    add_index :replies, :user_id
    add_index :replies, :project_id
  end
end
