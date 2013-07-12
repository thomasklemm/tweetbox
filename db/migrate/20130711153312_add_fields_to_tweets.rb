class AddFieldsToTweets < ActiveRecord::Migration
  def change
    add_column :tweets, :source, :text
    add_column :tweets, :lang, :text

    add_column :tweets, :retweet_count, :integer, default: 0
    add_column :tweets, :favorite_count, :integer, default: 0
  end
end
