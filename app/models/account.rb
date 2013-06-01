# == Schema Information
#
# Table name: accounts
#
#  created_at :datetime         not null
#  id         :integer          not null, primary key
#  name       :text             not null
#  updated_at :datetime         not null
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
end
