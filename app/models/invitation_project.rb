class InvitationProject < ActiveRecord::Base
  belongs_to :invitation
  belongs_to :project

  # REVIEW: Fails in Rails 4
  # validates :invitation, :project, presence: true
  validates :project, presence: true
end
