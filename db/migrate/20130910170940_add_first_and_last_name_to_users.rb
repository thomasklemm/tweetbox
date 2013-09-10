class AddFirstAndLastNameToUsers < ActiveRecord::Migration
  def up
    add_column :users, :first_name, :text
    add_column :users, :last_name, :text

    User.find_each do |user|
      user.first_name = user.name.split(' ')[0] || 'First name'
      user.last_name  = user.name.split(' ')[1] || 'Last name'
      user.save!
    end
  end

  def down
    remove_column :users, :first_name
    remove_column :users, :last_name
  end
end
