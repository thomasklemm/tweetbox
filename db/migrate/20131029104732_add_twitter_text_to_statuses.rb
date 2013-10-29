class AddTwitterTextToStatuses < ActiveRecord::Migration
  def change
    add_column :statuses, :twitter_text, :text
  end
end
