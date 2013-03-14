class CreateAuthors < ActiveRecord::Migration
  def change
    create_table :authors do |t|
      t.belongs_to :project
      t.integer :twitter_id, limit: 8
      t.text :name
      t.text :screen_name
      t.text :location
      t.text :description
      t.text :url
      t.boolean :verified, default: false
      t.integer :followers_count, default: 0
      t.integer :friends_count, default: 0
      t.text :profile_image_url

      t.timestamps
    end
    add_index :authors, :project_id
    add_index :authors, :twitter_id
    add_index :authors, [:project_id, :twitter_id], unique: true
  end
end
