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

require 'spec_helper'

describe InvitationProject do
  subject(:invitation_project) { Fabricate.build(:invitation_project) }
  it { should be_valid }

  it { should belong_to(:invitation) }
  it { should belong_to(:project) }

  it { should validate_presence_of(:invitation) }
  it { should validate_presence_of(:project) }
end
