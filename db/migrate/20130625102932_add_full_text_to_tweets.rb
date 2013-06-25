class AddFullTextToTweets < ActiveRecord::Migration
  def change
    add_column :tweets, :full_text, :text
  end
end
