# == Schema Information
#
# Table name: projects
#
#  account_id :integer
#  created_at :datetime         not null
#  id         :integer          not null, primary key
#  name       :string(255)
#  updated_at :datetime         not null
#
# Indexes
#
#  index_projects_on_account_id  (account_id)
#

require 'spec_helper'

describe Project do
  subject { Fabricate(:project) }
  it { should be_valid }

  it { should belong_to(:account) }

  it { should validate_presence_of(:account) }

  it { should allow_mass_assignment_of(:name) }
end
