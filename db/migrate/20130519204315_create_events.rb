class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.belongs_to :project, null: false
      t.belongs_to :tweet, null: false
      t.belongs_to :user, null: false
      t.text :target_state, null: false

      t.timestamps
    end

    add_index :events, [:project_id, :tweet_id]
  end
end
