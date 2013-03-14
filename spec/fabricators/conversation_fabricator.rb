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

Fabricator(:conversation) do
  project
  tweets { [Fabricate(:tweet), Fabricate(:tweet)] }
end
