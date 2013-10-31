class CreateSalesTweets < ActiveRecord::Migration
  def change
    create_table :sales_tweets do |t|
      t.text :text
      t.text :twitter_text

      t.timestamps
    end
  end
end
