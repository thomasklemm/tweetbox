class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.text :name, null: false

      t.timestamps
    end
  end
end
