shared_examples "an invitations subcontroller" do |actions|
  it { should be_kind_of(Invitations::BaseController) }

  let(:invitation) { Fabricate(:invitation) }
  let(:used_invitation) { Fabricate(:invitation, used: true) }

  actions.each do |action, verb|
    describe "ensures invitation code is present" do
      before { send(verb, action) }
      it { should redirect_to root_path }
      it { should set_the_flash.to('Please provide a valid invitation code.') }
    end

    describe "loads the invitation" do
      before { send(verb, action, code: invitation) }
      it { should assign_to(:invitation) }
      it { should_not set_the_flash }
    end

    describe "ensures invitation is found" do
      before { send(verb, action, code: 1) }
      it { should redirect_to root_path }
      it { should set_the_flash.to('Please provide a valid invitation code.') }
    end

    describe "ensures invitation has not already been used" do
      before { send(verb, action, code: used_invitation) }
      it { should redirect_to root_path }
      it { should set_the_flash.to('Your invitation code has already been used.') }
    end
  end
end
