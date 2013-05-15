# == Schema Information
#
# Table name: plans
#
#  created_at :datetime         not null
#  id         :integer          not null, primary key
#  name       :text
#  price      :integer          default(0), not null
#  trial      :boolean          default(FALSE), not null
#  updated_at :datetime         not null
#  user_limit :integer          not null
#

require 'spec_helper'

describe Plan do
  subject { Fabricate(:paid_plan) }
  it { should be_valid }

  it { should have_many(:accounts).dependent(:restrict) }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:price) }
  it { should validate_presence_of(:user_limit) }

  it "finds ordered paid plans" do
    Fabricate(:trial_plan)
    Fabricate(:paid_plan, name: 'One',   price: 0)
    Fabricate(:paid_plan, name: 'Three', price: 25)
    Fabricate(:paid_plan, name: 'Two',   price: 10)
    Fabricate(:paid_plan, name: 'Five',  price: 100)

    plan_names = Plan.paid_by_price.to_a.map(&:name)
    expect(plan_names).to eq(%w(Five Three Two One))
  end

  it "finds the trial plan" do
    paid = Fabricate(:paid_plan)
    trial = Fabricate(:trial_plan)

    expect(Plan.trial).to eq(trial)
  end
end

describe Plan, "paid" do
  subject { Fabricate(:paid_plan) }

  it "isn't free" do
    expect(subject).not_to be_free
  end

  it "is billed" do
    expect(subject).to be_billed
  end
end

describe Plan, "trial" do
  subject { Fabricate(:trial_plan) }

  it "is free" do
    expect(subject).to be_free
  end

  it "isn't billed" do
    expect(subject).not_to be_billed
  end
end

describe Plan, "paid with user limit" do
  subject { Fabricate(:paid_plan, user_limit: 10) }

  it "indicates whether or not more users can be created" do
    expect(subject.can_add_more_users?(9)).to be
    expect(subject.can_add_more_users?(10)).to be
    expect(subject.can_add_more_users?(11)).not_to be
  end
end

describe Plan, "trial with user limit" do
  subject { Fabricate(:trial_plan, user_limit: 30) }

  it "indicates whether or not more users can be created" do
    expect(subject.can_add_more_users?(29)).to be
    expect(subject.can_add_more_users?(30)).to be
    expect(subject.can_add_more_users?(31)).not_to be
  end
end
