# == Schema Information
#
# Table name: invitations
#
#  account_id :integer          not null
#  admin      :boolean          default(FALSE)
#  code       :text             not null
#  created_at :datetime         not null
#  email      :text             not null
#  id         :integer          not null, primary key
#  invitee_id :integer
#  issuer_id  :integer          not null
#  updated_at :datetime         not null
#  used_at    :datetime
#
# Indexes
#
#  index_invitations_on_account_id  (account_id)
#  index_invitations_on_code        (code) UNIQUE
#

class Invitation < ActiveRecord::Base
  belongs_to :account
  belongs_to :issuer, class_name: 'User'

  belongs_to :invitee, class_name: 'User'

  has_many :invitation_projects, dependent: :destroy
  has_many :projects, through: :invitation_projects

  validates :account,
            :issuer,
            :email,
            :code, presence: true
  validates :code, uniqueness: true

  after_initialize :generate_code

  # Invitations will become inactive after a certain timespan
  # to enhance security
  def active?
    new_record? || within_invitation_period?
  end

  def within_invitation_period?
    # TODO: Check logic
    created_at < ACTIVE_INVITATION_DURATION.ago
  end

  # Sends an invitation email sporting a link that helps registering
  def deliver_invitation_mail
    mail = InvitationMailer.invitation(self)
    mail.deliver
  end

  def accept(invitee)
    return false unless invitee.present?

    membership = create_membership!(invitee)
    mark_as_used!(invitee)
    create_projects!(membership)

    membership
  end

  def to_param
    code
  end

  private

  # Generates a random and unique invitation code
  def generate_code
    self.code ||= Random.new.code(32)
  end

  def create_membership!(invitee)
    Membership.create! do |membership|
      membership.user    = invitee
      membership.account = account
      membership.admin   = admin
    end
  end

  def mark_as_used!(invitee)
    self.invitee = invitee
    self.used = true
    self.save!
  end

  def create_projects!(membership)
    projects.map { |project| project.permissions.where(membership_id: membership.id).first_or_create! }
  end

  # Duration for which a saved invitation is considered active
  ACTIVE_INVITATION_DURATION = 7.days
end
