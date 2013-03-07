# Form objects using virtus
shared_examples "a form object" do
  it { should_not be_persisted }

  describe "activemodel compliant api" do
    it { should be_kind_of(ActiveModel::Conversion) }
    it { should be_kind_of(ActiveModel::Validations) }
    its(:class) { should be_kind_of(ActiveModel::Naming) }
  end
end
