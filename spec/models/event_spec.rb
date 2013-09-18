require 'spec_helper'

describe Event do
  subject(:event) { Fabricate.build(:event) }
  it { should be_valid }

  it { should belong_to(:user) }
  it { should belong_to(:eventable) }
end
