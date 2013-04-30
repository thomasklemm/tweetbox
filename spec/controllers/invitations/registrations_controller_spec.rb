require 'spec_helper'

describe Invitations::RegistrationsController do
  let(:user)       { Fabricate(:user) }
  let(:invitation) { Fabricate(:invitation) }

  let(:valid_signup_params)   { Fabricate.attributes_for(:invitation_signup, invitation: invitation) }
  let(:invalid_signup_params) { Fabricate.attributes_for(:invitation_signup, invitation: invitation, name: "") }

  describe "GET #new" do
    context "signed in user access" do
      it "redirects to join controller while preserving invitation code" do
        sign_in user
        get :new, code: invitation
        expect(response).to redirect_to(new_invitations_join_path(code: invitation))
      end
    end

    context "guest access" do
      before { get :new, code: invitation }
      it { should respond_with(:success) }
      it { should render_template(:new) }
      it { should_not set_the_flash }

      it "associates the signup with the invitation" do
        expect(assigns(:signup).invitation).to eq(invitation)
      end
    end
  end

  describe "POST #create" do
    context "with valid parameters" do
      before { post :create, registration: valid_signup_params, code: invitation }
      let(:signup) { assigns(:signup) }

      it { should redirect_to(projects_path) }
      it { should set_the_flash.to("Thanks for signing up.") }

      it "creates the user in the database" do
        expect(signup.user).to be_persisted
      end

      it "signs the new user in" do
        expect(subject.current_user).to eq(signup.user)
      end
    end

    context "with invalid parameters" do
      before { post :create, registration: invalid_signup_params, code: invitation }
      let(:signup) { assigns(:signup) }

      it { should render_template(:new) }
      it { should_not set_the_flash }

      it "doesn't persist the new user in the database" do
        expect(signup.user).to be_new_record
      end
    end
  end
end

describe Invitations::RegistrationsController, "ensures invitation" do
  actions = {
    new: :get,
    create: :post
  }

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
