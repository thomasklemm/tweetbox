require 'spec_helper'

describe InvitationProject do
  subject(:invitation_project) { Fabricate(:invitation_project) }
  it { should be_valid }

  it { should belong_to(:invitation) }
  it { should belong_to(:project) }

  # TODO: Enable validation
  pending { should validate_presence_of(:invitation) }
  it { should validate_presence_of(:project) }
end
