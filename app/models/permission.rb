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
  belongs_to :project
  belongs_to :membership
  belongs_to :user

  before_validation :set_user_from_membership, if: :membership_id_changed?
  before_validation :set_membership_from_user, if: :user_id_changed?
  before_validation :ensure_user_is_membership_user

  validates :project, :membership, :user, presence: true
  validate :membership_and_user_must_be_associated_with_project_account
  validates_uniqueness_of :membership_id, scope: :project_id

  private

  def set_user_from_membership
    self.user = membership.try(:user)
  end

  def set_membership_from_user
    self.membership = user.try(:membership)
  end

  # Validates that the user is the one referenced by the membership
  def ensure_user_is_membership_user
    self.user = membership.try(:user)
  end

  def membership_and_user_must_be_associated_with_project_account
    unless project && project.account && user && project.account.has_member?(user)
      errors.add(:membership, "is not associated with the project's account")
      errors.add(:user, "is not associated with the project's account")
    end
  end
end
