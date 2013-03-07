require 'spec_helper'

describe Invitation::Signup do
  subject { Fabricate(:invitation_signup) }
  it { should be_valid }

  it { should respond_to(:user) }
  it { should respond_to(:membership) }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:password) }

  it_should_behave_like "a form object"

end
