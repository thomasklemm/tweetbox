# == Schema Information
#
# Table name: permissions
#
#  created_at    :datetime         not null
#  id            :integer          not null, primary key
#  membership_id :integer          not null
#  project_id    :integer          not null
#  updated_at    :datetime         not null
#  user_id       :integer          not null
#
# Indexes
#
#  index_permissions_on_membership_and_project  (membership_id,project_id) UNIQUE
#  index_permissions_on_user_id_and_project_id  (user_id,project_id)
#

class Permission < ActiveRecord::Base
  belongs_to :membership
  belongs_to :project
  belongs_to :user

  validates :membership_id, :project_id, :user_id, presence: true
  validates_uniqueness_of :membership_id, scope: :project_id

  before_validation :assign_user_id_from_membership

  def user=(ignored)
    raise NotImplementedError, "Use Permission#membership= instead"
  end

  private

  def assign_user_id_from_membership
    self.user_id = membership.user_id if membership
  end
end
