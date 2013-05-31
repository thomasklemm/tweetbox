# == Schema Information
#
# Table name: invitations
#
#  account_id :integer          not null
#  admin      :boolean          default(FALSE)
#  code       :text             not null
#  created_at :datetime         not null
#  email      :text             not null
#  expires_at :datetime
#  id         :integer          not null, primary key
#  invitee_id :integer
#  issuer_id  :integer          not null
#  name       :text             not null
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
            :name,
            :email,
            :code, presence: true
  validates :code, uniqueness: true

  after_initialize :generate_code
  before_create :set_expiration_date

  def active?
    !used? && !expired?
  end

  def expired?
    expires_at < Time.current
  end

  def used?
    !!used_at
  end

  def to_param
    code
  end

  # Set the used_at flag
  def mark_as_used(invitee)
    self.invitee = invitee
    self.used_at = Time.current
    self.save!
  end

  # Sends an invitation email sporting a link that helps registering
  def deliver_mail
    mail = InvitationMailer.invitation(self)
    mail.deliver
  end

  private

  # Generates a random and unique invitation code
  def generate_code
    self.code ||= RandomCode.new.code(32)
  end

  def set_expiration_date
    self.expires_at = ACTIVE_INVITATION_PERIOD.from_now
  end

  ACTIVE_INVITATION_PERIOD = 7.days
end
