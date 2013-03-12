class CreateTwitterAccounts < ActiveRecord::Migration
  def change
    create_table :twitter_accounts do |t|
      t.belongs_to :project
      t.string :uid
      t.string :token
      t.string :token_secret
      t.integer :twitter_id
      t.string :name
      t.string :screen_name
      t.string :location
      t.string :description
      t.string :url
      t.string :profile_image_url

      t.timestamps
    end
    add_index :twitter_accounts, :project_id
    add_index :twitter_accounts, [:project_id, :uid], unique: true
  end
end
