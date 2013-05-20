class CreateTransitions < ActiveRecord::Migration
  def change
    create_table :transitions do |t|
      t.belongs_to :tweet, null: false
      t.belongs_to :user, null: false
      t.belongs_to :project, null: false

      t.text :target_state, null: false

      t.timestamps
    end

    add_index :transitions, :tweet_id
    add_index :transitions, :user_id
    add_index :transitions, :project_id
  end
end
