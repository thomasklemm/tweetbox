class AddFieldsToAuthors < ActiveRecord::Migration
  def change
    add_column :authors, :statuses_count, :integer, default: 0
  end
end
