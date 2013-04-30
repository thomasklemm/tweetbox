require 'spec_helper'

describe Invitations::JoinsController do
  let(:invitation) { Fabricate(:invitation) }
  let(:user)       { Fabricate(:user) }

  it_should_behave_like "an authenticated controller", {
    new: [:get],
    create: [:post]
  }

  let(:valid_join_params) { Fabricate.attributes_for(:invitation_join, invitation: invitation, user: user) }

  describe "GET #new" do
    before do
      sign_in user
      get :new, code: invitation
    end

    it { should respond_with(:success) }
    it { should render_template(:new) }
    it { should_not set_the_flash }

    it "associates the matching invitation" do
      expect(assigns(:join).invitation).to eq(invitation)
    end

    it "associates the current user" do
      expect(assigns(:join).user).to eq(subject.current_user)
    end
  end

  describe "POST #create" do
    context "with valid invitation and current user" do
      before do
        sign_in user
        post :create, join: valid_join_params, code: invitation
      end

      it { should redirect_to(projects_path) }
      it { should set_the_flash.to("You successfully accepted the invitation.") }

      it "creates the membership" do
        expect(user).to be_member_of(invitation.account)
      end
    end
  end
end

describe Invitations::JoinsController, "ensures invitation" do
  actions = {
    new: :get,
    create: :post
  }

  let(:user) { Fabricate(:user) }
  before { sign_in user }

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
