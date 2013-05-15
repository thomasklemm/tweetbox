class AddAuthorToTweets < ActiveRecord::Migration
  def change
    add_column :tweets, :author_id, :integer, limit: 8
    add_index :tweets, :author_id
    add_index :tweets, [:project_id, :author_id]
  end
end
