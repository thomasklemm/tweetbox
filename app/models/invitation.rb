# == Schema Information
#
# Table name: invitations
#
#  account_id :integer
#  admin      :boolean          default(FALSE), not null
#  code       :string(255)
#  created_at :datetime         not null
#  email      :string(255)
#  id         :integer          not null, primary key
#  invitee_id :integer
#  sender_id  :integer
#  updated_at :datetime         not null
#  used       :boolean          default(FALSE), not null
#
# Indexes
#
#  index_invitations_on_account_id  (account_id)
#

class Invitation < ActiveRecord::Base
  belongs_to :account
  belongs_to :sender, class_name: 'User'
  belongs_to :invitee, class_name: 'User'
  has_and_belongs_to_many :projects

  validates :account, :email, :sender, presence: true
  validates :code, presence: true, uniqueness: true

  after_initialize :generate_code!

  def to_param
    code
  end

  def sender_name
    sender.name
  end

  def sender_email
    sender.email
  end

  def account_name
    account.name
  end

  def send_mail!
    InvitationMailer.invitation(self).deliver
  end

  # TODO: Specs
  def accept!(invitee)
    return false unless invitee.present?

    membership = create_membership!(invitee)
    mark_as_used!(invitee)
    create_projects!(membership)

    membership
  end

  private

  def generate_code!
    self.code ||= SecureRandom.hex(12)
    self.code.force_encoding("UTF-8") if self.code.respond_to?(:encoding)
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
end
