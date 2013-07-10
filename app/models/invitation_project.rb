class InvitationProject < ActiveRecord::Base
  belongs_to :invitation
  belongs_to :project

  validates :invitation, :project, presence: true
end
