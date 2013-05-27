# == Schema Information
#
# Table name: memberships
#
#  account_id :integer          not null
#  admin      :boolean          default(FALSE), not null
#  created_at :datetime         not null
#  id         :integer          not null, primary key
#  updated_at :datetime         not null
#  user_id    :integer          not null
#
# Indexes
#
#  index_memberships_on_user_id_and_account_id  (user_id,account_id) UNIQUE
#

class Membership < ActiveRecord::Base
  belongs_to :user
  belongs_to :account

  has_many :permissions, dependent: :destroy
  has_many :projects, through: :permissions

  validates :user_id, :account_id, presence: true
  validates_uniqueness_of :user_id, scope: :account_id

  delegate :name, :email, to: :user

  scope :admin, where(admin: true)

  def self.by_name
    joins(:user).order('users.name')
  end
end
