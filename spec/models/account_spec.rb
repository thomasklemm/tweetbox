# == Schema Information
#
# Table name: accounts
#
#  created_at :datetime         not null
#  id         :integer          not null, primary key
#  name       :string(255)
#  updated_at :datetime         not null
#

require 'spec_helper'

describe Account do
  subject { Fabricate(:account) }
  it { should be_valid }

  it { should have_many(:memberships) }
  it { should have_many(:users).through(:memberships) }
  it { should have_many(:admins).through(:memberships) }
  it { should have_many(:non_admins).through(:memberships) }

  it { should have_many(:projects) }

  it { should validate_presence_of(:name) }

  it { should allow_mass_assignment_of(:name) }
end
