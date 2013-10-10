class AddStateToSearches < ActiveRecord::Migration
  def change
    add_column :searches, :state, :text
  end
end
