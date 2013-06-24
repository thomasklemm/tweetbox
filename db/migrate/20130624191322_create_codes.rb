class CreateCodes < ActiveRecord::Migration
  def change
    create_table :codes do |t|
      t.belongs_to :tweet
      t.timestamps
    end
    add_index :codes, :tweet_id
  end
end
