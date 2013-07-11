class AddMoreFieldsToAuthors < ActiveRecord::Migration
  def change
    add_column :authors, :joined_twitter_at, :datetime
    add_column :authors, :lang, :text
    add_column :authors, :time_zone, :text
  end
end
