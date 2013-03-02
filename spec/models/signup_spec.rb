require 'spec_helper'

describe Signup do
  subject { Fabricate(:signup) }
  it { should be_valid }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:password) }
  it { should validate_presence_of(:company_name) }

  it { should respond_to(:user) }
  it { should respond_to(:account) }
  it { should respond_to(:membership) }
  it { should respond_to(:project) }

  it 'complies with the activemodel api' do
    expect(subject.class).to be_kind_of(ActiveModel::Naming)
    should_not be_persisted
    should be_kind_of(ActiveModel::Conversion)
    should be_kind_of(ActiveModel::Validations)
  end

end

describe Signup, 'with a valid user and account' do
  subject { Fabricate(:signup) }
  it { should be_valid }

  before do
    @result = subject.save # time instense
  end

  it 'returns true' do
    expect(@result).to be_true
  end

  its(:user)       { should be_valid }
  its(:account)    { should be_valid }
  its(:membership) { should be_valid }
  its(:project)    { should be_valid }

  its(:user)       { should be_persisted }
  its(:account)    { should be_persisted }
  its(:membership) { should be_persisted }
  its(:project)    { should be_persisted }

  it 'assigns the trial plan to the created account' do
    expect(subject.account.plan).to be_trial
  end

  it 'creates an admin membership for the user' do
    expect(subject.user).to be_admin_of(subject.account)
  end

  it 'assigns permissions when creating the project' do
    expect(subject.user).to be_member_of(subject.project)
  end
end
