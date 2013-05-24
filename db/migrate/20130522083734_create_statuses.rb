class CreateStatuses < ActiveRecord::Migration
  def change
    create_table :statuses do |t|
      t.belongs_to :project, null: false
      t.belongs_to :user, null: false
      t.belongs_to :twitter_account, null: false
      t.text :code, null: false
      t.text :text, null: false
      t.text :posted_text
      t.datetime :posted_at

      t.belongs_to :in_reply_to_tweet
      t.integer :in_reply_to_status_id, limit: 8

      t.timestamps
    end
    add_index :statuses, :project_id
    add_index :statuses, :code, unique: true
  end
end
