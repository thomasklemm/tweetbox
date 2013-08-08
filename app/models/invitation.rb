class Invitation < ActiveRecord::Base
  # TODO: Rename code to token

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
  before_create :set_expires_at

  scope :by_date, -> { order('invitations.created_at asc') }

  def active?
    !used? && !expired?
  end

  def expired?
    expires_at && expires_at < Time.current
  end

  def used?
    (used_at || invitee).present?
  end

  def use!(invitee)
    raise "An invitation can only be used once" if used?

    self.invitee = invitee
    self.used_at = Time.current
    self.save!
  end

  def deactivate!
    touch(:expires_at)
  end

  def reactivate!
    self.expires_at = ACTIVE_INVITATION_PERIOD.from_now
    self.save!
  end

  def to_param
    code
  end

  # Sends an invitation email sporting a link that helps registering
  def deliver_mail
    mail = InvitationMailer.invitation(self)
    mail.deliver
  end

  private

  # Generates a random and unique invitation code
  def generate_code
    self.code ||= Tokenizer.random_token(16)
  end

  def set_expires_at
    self.expires_at = ACTIVE_INVITATION_PERIOD.from_now
  end

  ACTIVE_INVITATION_PERIOD = 1.week
end
