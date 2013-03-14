class CreateConversations < ActiveRecord::Migration
  def change
    create_table :conversations do |t|
      t.belongs_to :project

      t.timestamps
    end
    add_index :conversations, :project_id
  end
end
