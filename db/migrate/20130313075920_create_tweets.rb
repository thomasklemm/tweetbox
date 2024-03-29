class CreateTweets < ActiveRecord::Migration
  def change
    create_table :tweets do |t|
      t.belongs_to :project, null: false
      t.belongs_to :twitter_account, null: false
      t.belongs_to :author, null: false

      t.integer :twitter_id, limit: 8, null: false
      t.text :text
      t.integer :in_reply_to_status_id, limit: 8
      t.integer :in_reply_to_user_id, limit: 8

      t.text :state

      t.timestamps
    end

    add_index :tweets, :project_id
    add_index :tweets, [:project_id, :twitter_id], unique: true
    add_index :tweets, [:project_id, :author_id]
    add_index :tweets, [:project_id, :state]
  end
end
