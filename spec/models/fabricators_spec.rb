require 'spec_helper'

describe Fabricate.build(:user), 'Fabrication of user' do
  it { should be_valid }
end
