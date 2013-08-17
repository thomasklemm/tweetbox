class RemoveFullTextFromTweets < ActiveRecord::Migration
  def up
    remove_column :tweets, :full_text
  end

  def down
    add_column :tweets, :full_text, :text
  end
end
