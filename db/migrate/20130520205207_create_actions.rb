class CreateActions < ActiveRecord::Migration
  def change
    create_table :actions do |t|
      t.text :type, null: false
      t.belongs_to :tweet, null: false
      t.belongs_to :user, null: false
      t.belongs_to :project, null: false
      t.text :text
      t.belongs_to :twitter_account
      t.datetime :posted_at

      t.timestamps
    end
    add_index :actions, :tweet_id
    add_index :actions, :user_id
    add_index :actions, :project_id
  end
end
