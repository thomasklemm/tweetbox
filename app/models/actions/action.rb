# # == Schema Information
# #
# # Table name: actions
# #
# #  created_at         :datetime         not null
# #  id                 :integer          not null, primary key
# #  posted_at          :datetime
# #  project_id         :integer          not null
# #  text               :text
# #  tweet_id           :integer          not null
# #  twitter_account_id :integer
# #  type               :text             not null
# #  updated_at         :datetime         not null
# #  user_id            :integer          not null
# #
# # Indexes
# #
# #  index_actions_on_project_id  (project_id)
# #  index_actions_on_tweet_id    (tweet_id)
# #  index_actions_on_user_id     (user_id)
# #

# class Action
#   # Primary fields
#   belongs_to :tweet
#   belongs_to :user
#   belongs_to :project

#   validates :tweet, :user, :project, presence: true

#   # Secondary fields
#   belongs_to :twitter_account

#   before_validation :assign_project_id_from_tweet

#   def project=(ignored)
#     raise NotImplementedError, "Use Action#tweet= instead"
#   end

#   private

#   def assign_project_id_from_tweet
#     self.project_id = tweet.try(:project_id)
#   end
# end

class Action
end
