class CreateLeads < ActiveRecord::Migration
  def change
    create_table :leads do |t|
      t.integer :twitter_id, limit: 8

      t.text :screen_name
      t.text :name

      t.text :description
      t.text :location
      t.text :profile_image_url
      t.text :url

      t.integer :followers_count, default: 0
      t.integer :statuses_count, default: 0
      t.integer :friends_count, default: 0

      t.datetime :joined_twitter_at

      t.text :lang
      t.text :time_zone

      t.boolean :verified
      t.boolean :following

      t.text :score

      t.timestamps
    end

    add_index :leads, :twitter_id, unique: true
    add_index :leads, :screen_name
    add_index :leads, :followers_count
    add_index :leads, :score
  end
end
