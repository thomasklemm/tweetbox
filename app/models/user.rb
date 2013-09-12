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

  # Events (engagements relevant to our business)
  has_many :events

  # Devise validates email on presence and uniqueness (also when user changes his email)
  # Devise validates password on presence, confirmation, and length
  validates :first_name, :last_name, presence: true

  scope :by_date, -> { order(created_at: :asc) }

  def admin_of?(account)
    return false unless account.persisted? && account == membership.try(:account)
    membership.admin?
  end

  def member_of?(account_or_project)
    account_or_project.has_member?(self)
  end

  def full_name
    "#{first_name} #{last_name}"
  end
  alias_method :name, :full_name

  # Gravatar with retro fallback
  def gravatar_image_url(size_in_pixels=32)
    email_hash = Digest::MD5.hexdigest(email.strip.downcase)
    "https://secure.gravatar.com/avatar/#{ email_hash }?s=#{ size_in_pixels.to_i }&d=retro"
  end

  def to_param
    "#{ id }-#{ name.parameterize }"
  end

  def mixpanel_id
    "user_#{ id }"
  end

  include Rails.application.routes.url_helpers
  def mixpanel_hash
    {
      '$username'    => "User: #{full_name}",
      '$first_name'  => first_name,
      '$last_name'   => last_name,
      '$email'       => email,
      'Account Name' => account.name,
      'Account URL'  => dash_account_url(account)
    }
  end
end
