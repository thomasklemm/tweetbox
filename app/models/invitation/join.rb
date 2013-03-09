class Invitation::Join
  include FormObject

  attribute :invitation, Invitation
  validates :invitation, presence: true

  attribute :user, User
  validates :user, presence: true
end
