class CreateFavorites < ActiveRecord::Migration
  def change
    create_table :favorites do |t|
      t.belongs_to :tweet, null: false
      t.belongs_to :user, null: false
      t.belongs_to :project, null: false

      t.belongs_to :twitter_account
      t.datetime :posted_at
      t.datetime :undone_at

      t.timestamps
    end

    add_index :favorites, :tweet_id
    add_index :favorites, :user_id
    add_index :favorites, :project_id
  end
end
