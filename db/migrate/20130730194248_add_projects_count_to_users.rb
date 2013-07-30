class AddProjectsCountToUsers < ActiveRecord::Migration
  def up
    add_column :users, :projects_count, :integer

    # Update projects count on users
    User.find_each do |user|
      user.projects_count = user.projects.length
      user.save!
    end
  end

  def down
    remove_column :users, :projects_count
  end
end
