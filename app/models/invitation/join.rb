class Invitation::Join
  include FormObject

  attribute :invitation, Invitation
  validates :invitation, presence: true

  attribute :user, User
  validates :user, presence: true

  attr_reader :membership

  def account
    invitation.account
  end

  def save
    if valid?
      persist!
      true
    else
      false
    end
  end

  private

  def persist!
    create_or_update_membership
    create_or_update_permissions
  end

  def create_or_update_membership
    @membership = account.memberships.where(user_id: user.id).first_or_initialize
    @membership.admin = invitation.admin
    @membership.save
  end

  def create_or_update_permissions
    projects = account.projects.where(id: invitation.project_ids)
    projects.each do |project|
      project.permissions.where(membership_id: @membership.id).first_or_create!
    end
  end
end
