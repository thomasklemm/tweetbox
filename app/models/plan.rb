# == Schema Information
#
# Table name: plans
#
#  created_at :datetime         not null
#  id         :integer          not null, primary key
#  name       :string(255)
#  price      :integer          default(0), not null
#  trial      :boolean          default(FALSE), not null
#  updated_at :datetime         not null
#  user_limit :integer          not null
#

class Plan < ActiveRecord::Base
  has_many :accounts, dependent: :restrict

  validates :name, :price, :user_limit, presence: true

  def self.ordered
    order('price DESC')
  end

  def self.paid_by_price
    paid.ordered
  end

  def self.trial
    where(trial: true).first!
  end

  def self.paid
    where(trial: false)
  end

  def free?
    price.zero?
  end

  def billed?
    !free?
  end

  def can_add_more_users?(amount)
    amount <= user_limit
  end
end
