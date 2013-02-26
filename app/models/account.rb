# == Schema Information
#
# Table name: accounts
#
#  created_at :datetime         not null
#  id         :integer          not null, primary key
#  name       :string(255)
#  updated_at :datetime         not null
#

class Account < ActiveRecord::Base
  validates :name, presence: true

  # Memberships and members
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  has_many :admins, through: :memberships,
                    source: :user,
                    conditions: { 'memberships.admin' => true }
  has_many :non_admins, through: :memberships,
                        source: :user,
                        conditions: { 'memberships.admin' => false }

  # Projects
  has_many :projects, dependent: :destroy

  def has_member?(user)
    memberships.exists?(user_id: user.id)
  end

  attr_accessible :name
end
