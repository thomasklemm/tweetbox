# Form objects using virtus
shared_examples_for Reformer do
  it { should be_kind_of(Reformer) }

  it { should be_kind_of(Virtus) }
  it { should be_kind_of(ActiveModel::Conversion) }
  it { should be_kind_of(ActiveModel::Validations) }
  it "does comply with ActiveModel naming" do
    expect(subject.class).to be_kind_of(ActiveModel::Naming)
  end

  it { should_not be_persisted }
end
