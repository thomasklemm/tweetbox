class Invitation::Base
  include FormObject

  attribute :invitation, Invitation
  validates :invitation, presence: true

  attribute :user, User
  validates :user, presence: true

  def account
    invitation.try(:account)
  end

  def code
    invitation.try(:code)
  end

  def code=(new_code)
    # self.invitation = Invitation.find_by_code!(new_code)
  end

  private

  def persist!
    create_membership_and_permissions
    use_invitation!
  end

  def create_membership_and_permissions
    @membership = account.memberships.create! do |membership|
      membership.user = user
      membership.admin = invitation.admin
    end

    invitation.projects.each do |project|
      project.permissions.where(membership_id: @membership.id).first_or_create!
    end
  end

  def use_invitation!
    invitation.update_attributes!(used: true)
  end
end
