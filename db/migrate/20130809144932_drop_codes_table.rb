class DropCodesTable < ActiveRecord::Migration
  def up
    drop_table :codes
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
