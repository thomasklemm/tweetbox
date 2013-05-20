class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.belongs_to :tweet, null: false
      t.belongs_to :user, null: false
      t.belongs_to :project, null: false

      t.text :text, null: false

      t.timestamps
    end

    add_index :comments, :tweet_id
    add_index :comments, :user_id
    add_index :comments, :project_id
  end
end
