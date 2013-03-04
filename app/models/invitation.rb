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
  has_and_belongs_to_many :projects

  validates :email, :account, :sender, presence: true

  before_create :generate_code

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

  def send_email
    InvitationMailer.invitation(self).deliver
  end

  private

  def generate_code
    self.code ||= SecureRandom.hex(16)
    self.code = self.code.force_encoding("UTF-8") if self.code.respond_to?(:encoding)
  end
end
