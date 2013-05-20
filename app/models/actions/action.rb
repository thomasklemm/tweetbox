# Like STI but with different database tables
class Action < ActiveRecord::Base
  self.abstract_class = true

  belongs_to :tweet, counter_cache: true
  belongs_to :user
  belongs_to :project

  validates :tweet, :user, :project, presence: true

  before_validation :assign_project_id_from_tweet

  def project=(ignored)
    raise NotImplementedError, "Use Eventable#tweet= instead"
  end

  private

  def assign_project_id_from_tweet
    self.project_id = tweet.try(:project_id)
  end
end
