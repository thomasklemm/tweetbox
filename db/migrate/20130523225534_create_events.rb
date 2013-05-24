class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.belongs_to :tweet, null: false
      t.belongs_to :user, null: false
      t.belongs_to :project, null: false
      t.text :kind, null: false
      t.text :text

      t.timestamps
    end
    add_index :events, :tweet_id
    add_index :events, :user_id
    add_index :events, :project_id
  end
end
