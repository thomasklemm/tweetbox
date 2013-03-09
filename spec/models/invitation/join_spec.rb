require 'spec_helper'

describe Invitation::Join do
  subject { Fabricate(:invitation_join) }
  it { should be_valid }

  it_should_behave_like FormObject

  it { should respond_to(:invitation) }
  it { should respond_to(:invitation=) }
  it { should validate_presence_of(:invitation) }

  it { should respond_to(:user) }
  it { should respond_to(:user=) }
  it { should validate_presence_of(:user) }
end
