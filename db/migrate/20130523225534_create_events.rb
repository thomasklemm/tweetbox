class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.belongs_to :tweet
      t.belongs_to :user
      t.belongs_to :project
      t.text :kind

      t.timestamps
    end
    add_index :events, :tweet_id
    add_index :events, :user_id
    add_index :events, :project_id
  end
end
