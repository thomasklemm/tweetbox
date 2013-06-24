# == Schema Information
#
# Table name: invitation_projects
#
#  id            :integer          not null, primary key
#  invitation_id :integer          not null
#  project_id    :integer          not null
#
# Indexes
#
#  index_invitation_projects_on_invitation_id_and_project_id  (invitation_id,project_id) UNIQUE
#

Fabricator(:invitation_project) do
  invitation
  project
end
