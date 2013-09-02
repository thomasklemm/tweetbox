class Event < ActiveRecord::Base
  belongs_to :tweet, counter_cache: true, touch: true
  belongs_to :user
  belongs_to :project

  validates :tweet, :user, :project, presence: true

  VALID_KINDS = %w(resolve start_reply post_reply post retweet favorite unfavorite)
  validates :kind, presence: true, inclusion: { in: VALID_KINDS }

  before_validation :assign_project_id_from_tweet

  # Cast symbols to strings before writing and validating the kind of event
  def kind=(kind)
    super kind.try(:to_s)
  end

  def project=(ignored)
    raise NotImplementedError, "Use Event#tweet= instead"
  end

  private

  def assign_project_id_from_tweet
    self.project_id = tweet.try(:project_id)
  end
end
