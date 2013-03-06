require 'spec_helper'

describe InvitationSignup do
  subject { Fabricate(:invitation_signup) }
  it { should be_valid }

  it { should respond_to(:invitation) }
  it { should respond_to(:invitation=) }
  it { should validate_presence_of(:invitation) }

  it { should respond_to(:user) }
  it { should respond_to(:user=) }
  it { should validate_presence_of(:user) }

  it "complies with the activemodel api" do
    expect(subject.class).to be_kind_of(ActiveModel::Naming)
    should_not be_persisted
    should be_kind_of(ActiveModel::Conversion)
    should be_kind_of(ActiveModel::Validations)
  end

  let(:user)       { Fabricate(:user) }
  let(:invitation) { Fabricate(:invitation) }
  let(:admin_invitation) { Fabricate(:invitation, admin: true) }

  context "with invitation to become account admin" do
    subject { Fabricate(:invitation_signup, invitation: admin_invitation, user: user) }
    it { should be_valid }

    before { subject.save }

    it "marks the user as admin" do
      expect(subject.membership).to be_admin
      expect(subject.user).to be_admin_of(subject.invitation.account)
    end
  end

  context "with invitation to become account admin" do
    subject { Fabricate(:invitation_signup, invitation: invitation, user: user) }
    it { should be_valid }

    before { subject.save }

    it "marks the user as admin" do
      expect(subject.membership).to_not be_admin
      expect(subject.user).to_not be_admin_of(subject.invitation.account)
    end
  end
end

describe InvitationSignup, 'with an existing user' do
  let(:invitation) { Fabricate(:invitation) }
  let(:user)       { Fabricate(:user) }

  subject { Fabricate(:invitation_signup, invitation: invitation, user: user) }
  it { should be_valid }

  before do
    @result = subject.save # time intense
  end

  it "returns true" do
    expect(@result).to be_true
  end

  its(:user)       { should be_persisted }
  its(:membership) { should be_persisted }

  it "makes user a member of the account" do
    expect(user).to be_member_of(invitation.account)
  end

  it "marks the invitation as used" do
    expect(invitation).to be_used
  end
end

describe InvitationSignup, 'with a new user' do
  let(:invitation) { Fabricate(:invitation) }
  let(:user)       { Fabricate.attributes_for(:user) }

  subject do
    Fabricate(:invitation_signup, invitation: invitation, name: user[:name], email: user[:email], password: user[:password])
  end

  before do
    @result = subject.save # time intense
  end

  it { should be_valid }

  it "returns true" do
    expect(@result).to be_true
  end

  its(:user)       { should be_persisted }
  its(:membership) { should be_persisted }

  it "makes user a member of the account" do
    expect(subject.user).to be_member_of(invitation.account)
  end

  it "marks the invitation as used" do
    expect(invitation).to be_used
  end
end
