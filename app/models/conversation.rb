# == Schema Information
#
# Table name: conversations
#
#  created_at :datetime         not null
#  id         :integer          not null, primary key
#  project_id :integer
#  updated_at :datetime         not null
#
# Indexes
#
#  index_conversations_on_project_id  (project_id)
#

class Conversation < ActiveRecord::Base
  # Project
  belongs_to :project
  validates :project, presence: true

  # Tweets
  has_many :tweets
end
