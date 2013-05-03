class CreateSearches < ActiveRecord::Migration
  def change
    create_table :searches do |t|
      t.belongs_to :twitter_account
      t.belongs_to :project
      t.text :term

      t.timestamps
    end
    add_index :searches, :twitter_account_id
    add_index :searches, :project_id
  end
end
