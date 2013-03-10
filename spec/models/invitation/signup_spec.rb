require 'spec_helper'

describe Invitation::Signup do
  subject { Fabricate(:invitation_signup) }
  it { should be_valid }

  it_should_behave_like FormObject

  it { should respond_to(:invitation) }
  it { should respond_to(:invitation=) }
  it { should validate_presence_of(:invitation) }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:password) }

  it { should respond_to(:user) }
  it { should respond_to(:membership) }
end
