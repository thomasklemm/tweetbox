# == Schema Information
#
# Table name: accounts
#
#  created_at     :datetime         not null
#  id             :integer          not null, primary key
#  name           :text             not null
#  projects_count :integer
#  updated_at     :datetime         not null
#

class Account < ActiveRecord::Base
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  has_many :admins, through: :memberships,
                    source: :user,
                    conditions: { 'memberships.admin' => true }
  has_many :non_admins, through: :memberships,
                        source: :user,
                        conditions: { 'memberships.admin' => false }

  has_many :projects, dependent: :restrict
  has_many :invitations, dependent: :destroy

  validates :name, presence: true

  def has_member?(user)
    memberships.exists?(user_id: user.id)
  end

  # Grant the given user an admin membership of the account
  # Creates permissions for each project on the account, too
  def grant_admin_membership!(user)
    upgrade_membership_to_admin_membership(user)
    create_project_permissions(user)
  end

  private

  # Grant the given user an admin membership of the account
  def upgrade_membership_to_admin_membership(user)
    raise Pundit::NotAuthorizedError unless has_member?(user)
    membership = user.membership
    membership.admin = true && membership.save!
  end

  # Create permissions for all projects on the account for the given user
  def create_project_permissions(user)
    projects.each { |project| user.projects << project }
  end
end
