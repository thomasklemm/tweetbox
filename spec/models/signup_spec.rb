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
  it { should respond_to(:project) }

  it 'persists user, account with trial plan and project' do
    subject.save # FIXME: time intense
    expect(subject.user).to be_valid
    expect(subject.account).to be_valid
    expect(subject.project).to be_valid

    expect(subject.user).to be_persisted
    expect(subject.account).to be_persisted
    expect(subject.project).to be_persisted

    expect(subject.account.plan).to be_trial
  end

  it 'complies with the activemodel api' do
    expect(subject.class).to be_kind_of(ActiveModel::Naming)
    should_not be_persisted
    should be_kind_of(ActiveModel::Conversion)
    should be_kind_of(ActiveModel::Validations)
  end
end
