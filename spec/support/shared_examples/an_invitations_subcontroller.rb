shared_examples_for "an invitations subcontroller" do |actions|
  it { should be_kind_of(Invitations::BaseController) }

  actions.each do |action, verb|
    describe "ensures invitation code is present" do
      before { send(verb, action) }
      it { should redirect_to root_path }
      it { should set_the_flash.to('Please provide a valid invitation code.') }
    end

    describe "loads the invitation" do
      let(:invitation) { Fabricate(:invitation) }
      before { send(verb, action, code: invitation) }
      it "loads the invitation" do
        expect(assigns(:invitation)).to eq(invitation)
      end
      it { should_not set_the_flash }
    end

    describe "ensures invitation is found" do
      before { send(verb, action, code: 1) }
      it { should redirect_to root_path }
      it { should set_the_flash.to('Please provide a valid invitation code.') }
    end

    describe "ensures invitation has not already been used" do
      let(:used_invitation) { Fabricate(:invitation, used: true) }
      before { send(verb, action, code: used_invitation) }
      it { should redirect_to root_path }
      it { should set_the_flash.to('Your invitation code has already been used.') }
    end
  end
end
