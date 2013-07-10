class Membership < ActiveRecord::Base
  belongs_to :user
  belongs_to :account

  has_many :permissions, dependent: :destroy
  has_many :projects, through: :permissions

  validates :user, :account, presence: true
  validates_uniqueness_of :user_id, scope: :account_id

  def admin!
    self.admin = true and self.save!
  end
end
