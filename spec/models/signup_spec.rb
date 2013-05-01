require 'spec_helper'

describe Signup do
  subject(:signup) { Fabricate(:signup) }
  it { should be_valid }

  it_should_behave_like FormObject

  it { should respond_to(:user) }
  it { should respond_to(:account) }
  it { should respond_to(:membership) }
  it { should respond_to(:project) }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:password) }
  it { should validate_presence_of(:company_name) }
end

describe Signup, 'with a valid user and account' do
  # Trial plan must be present in the database
  before { Fabricate(:trial_plan) }

  subject(:signup) { Fabricate.build(:signup) }
  it { should be_valid }

  before do
    @result = signup.save # time intense
  end

  it 'returns true' do
    expect(@result).to be_true
  end

  its(:user)       { should be_persisted }
  its(:account)    { should be_persisted }
  its(:membership) { should be_persisted }
  its(:project)    { should be_persisted }

  it 'assigns the trial plan to the created account' do
    expect(signup.account.plan).to be_trial
  end

  it 'creates an admin membership for the user' do
    expect(signup.user).to be_admin_of(signup.account)
  end

  it 'assigns permissions when creating the project' do
    expect(signup.user).to be_member_of(signup.project)
  end
end

