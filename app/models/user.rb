# == Schema Information
#
# Table name: users
#
#  confirmation_sent_at   :datetime
#  confirmation_token     :text
#  confirmed_at           :datetime
#  created_at             :datetime         not null
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :text
#  email                  :text             default(""), not null
#  encrypted_password     :text             default(""), not null
#  id                     :integer          not null, primary key
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :text
#  name                   :text             default(""), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :text
#  sign_in_count          :integer          default(0)
#  unconfirmed_email      :text
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable,
         :validatable, :confirmable

  # Memberships and accounts
  has_one :membership
  has_one :account, through: :membership

  # Permissions and projects
  has_many :permissions
  has_many :projects, through: :permissions

  # Devise validates email on presence and uniqueness
  #  (also when user changes his email)
  # Devise validates password on presence, confirmation, and length
  validates :name, presence: true

  # Named scopes
  scope :by_name, -> { order('users.name') }
  scope :by_creation_date, ->(direction) { order('users.created_at') }

  def admin_of?(account)
    membership.account == account && membership.admin?
  end

  def member_of?(account_or_project)
    account_or_project.has_member?(self)
  end
end
