# == Schema Information
#
# Table name: users
#
#  confirmation_sent_at   :datetime
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  created_at             :datetime         not null
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string(255)
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  id                     :integer          not null, primary key
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string(255)
#  name                   :string(255)      default(""), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string(255)
#  sign_in_count          :integer          default(0)
#  unconfirmed_email      :string(255)
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

  # Devise validates email on presence and uniqueness (also when user changes his email)
  # Devise validates password on presence, confirmation, and length
  validates :name, presence: true

  # Memberships and accounts
  has_many :memberships
  has_many :accounts, through: :memberships

  # Permissions and projects
  has_many :permissions
  has_many :projects, through: :permissions

  def admin_of?(account)
    memberships.exists?(account_id: account.id, admin: true)
  end

  def member_of?(account_or_project)
    account_or_project.has_member?(self)
  end

  def self.by_name
    order('users.name')
  end

  def self.search(query)
    return [] if query.nil?
    query &&= "%#{ query }%"
    where('name LIKE ? OR email LIKE ?', query, query)
  end

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me # project_ids
end
