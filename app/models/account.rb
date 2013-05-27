# == Schema Information
#
# Table name: accounts
#
#  created_at       :datetime         not null
#  id               :integer          not null, primary key
#  name             :text             not null
#  plan_id          :integer
#  trial_expires_at :datetime
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_accounts_on_plan_id           (plan_id)
#  index_accounts_on_trial_expires_at  (trial_expires_at)
#

class Account < ActiveRecord::Base
  # Memberships and users
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  has_many :admins, through: :memberships,
                    source: :user,
                    conditions: { 'memberships.admin' => true }
  has_many :non_admins, through: :memberships,
                        source: :user,
                        conditions: { 'memberships.admin' => false }

  # Projects
  has_many :projects, dependent: :restrict

  # Invitations
  has_many :invitations, dependent: :destroy

  # Validations
  validates :name, presence: true

  def has_member?(user)
    memberships.exists?(user_id: user.id)
  end

  def users_by_name
    users.by_name
  end

  def projects_by_name
    projects.by_name
  end

  def memberships_by_name
    memberships.by_name
  end

  # TODO: Cache projects_count
  def projects_count
    projects.count
  end
end
