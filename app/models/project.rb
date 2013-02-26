# == Schema Information
#
# Table name: projects
#
#  account_id :integer
#  created_at :datetime         not null
#  id         :integer          not null, primary key
#  name       :string(255)
#  updated_at :datetime         not null
#
# Indexes
#
#  index_projects_on_account_id  (account_id)
#

class Project < ActiveRecord::Base
  # Account
  belongs_to :account
  validates :account, presence: true

  # Permissions and members
  has_many :permissions, dependent: :destroy
  has_many :users, through: :permissions

  validates :name, presence: true

  after_create :setup_permissions
  after_update :update_permissions

  def self.visible_to(user)
    where(id: user.project_ids)
  end

  def self.by_name
    order('projects.name')
  end

  def has_member?(user)
    permissions.
      joins(:membership).
      exists?(memberships: { user_id: user.id })
  end

  # We have to define there here instead of mixing them in,
  # because ActiveRecord does the same.

  def user_ids=(new_user_ids)
    @new_user_ids = new_user_ids.reject { |user_id| user_id.blank? }
  end

  def users
    if new_record?
      permissions.map { |permission| permission.membership.user }
    else
      permissions.includes(:user).map { |permission| permission.user }
    end
  end

  def user_ids
    users.map(&:id)
  end

  attr_accessible :name

  private

  def setup_permissions
    @new_user_ids ||= []
    @new_user_ids += admin_user_ids
    removed_user_ids = self.user_ids - @new_user_ids
    added_user_ids = @new_user_ids - self.user_ids

    permissions.where(user_id: removed_user_ids).destroy_all
    added_user_ids.each do |added_user_id|
      membership = account.memberships.where(user_id: added_user_id).first
      permissions.create! do |permission|
        permission.membership_id = membership.id
      end
    end
  end

  def update_permissions
    setup_permissions if @new_user_ids
  end

  def admin_user_ids
    account.
      memberships.
      where(admin: true).
      select(:user_id).
      map(&:user_id)
  end
end
