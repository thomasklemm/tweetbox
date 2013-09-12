class CreateNewEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.text :name
      t.belongs_to :user, index: true
      t.belongs_to :eventable, polymorphic: true, index: true

      t.timestamps
    end
  end
end
