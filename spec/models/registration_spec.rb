require 'spec_helper'

describe Registration do
  subject(:registration) { Fabricate(:registration) }
  it { should be_valid }

  it_should_behave_like Reformer

  it { should respond_to(:user) }
  it { should respond_to(:invitation) }
  it { should respond_to(:membership) }

  it { should validate_presence_of(:first_name) }
  it { should validate_presence_of(:last_name) }
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:password) }
end

describe Registration, 'valid user and invitation_code fields' do
  subject(:registration) { Fabricate(:registration) }

  before do
    @result = registration.save # time intense
  end

  it 'returns true' do
    expect(@result).to be_true
  end

  its(:user)       { should be_persisted }
  its(:membership) { should be_persisted }
  its(:invitation) { should be_used }

  it "accepts the invitation" do
    expect(registration.invitation).to be_used
    expect(registration.invitation.invitee).to eq(registration.user)
  end

  it 'creates a non-admin account membership for the user' do
    expect(registration.user).to be_member_of(registration.invitation.account)
    expect(registration.user).to_not be_admin_of(registration.invitation.account)
  end

  it 'assigns permissions for projects assigned to the invitation' do
    expect(registration.user).to be_member_of(registration.invitation.projects.first)
  end
end
