class CreateCustomEvents < ActiveRecord::Migration
  def change
    create_table :custom_events do |t|
      t.belongs_to :tweet, null: false
      t.belongs_to :user, null: false
      t.belongs_to :project, null: false

      t.text :text, null: false

      t.timestamps
    end

    add_index :custom_events, :tweet_id
    add_index :custom_events, :user_id
    add_index :custom_events, :project_id
  end
end
