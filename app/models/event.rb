class Event < ActiveRecord::Base
  belongs_to :tweet
  belongs_to :user
  belongs_to :project
  validates :tweet, :user, :project, presence: true

  VALID_KINDS_OF_EVENTS = %w(opened closed posted retweeted favorited unfavorited)
  validates :kind, presence: true, inclusion: { in: VALID_KINDS_OF_EVENTS }
end
