require 'spec_helper'

describe Invitations::SignupsController do
  it_should_behave_like "an invitations subcontroller", {
    :new => :get,
    :create => :post
  }

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
      it { should assign_to(:signup) }

      it "associates the signup with the invitation" do
        expect(assigns(:signup).invitation).to eq(invitation)
      end
    end
  end

  describe "POST #create" do
    context "with valid parameters" do
      before { post :create, signup: valid_signup_params }
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
      before { post :create, signup: invalid_signup_params }
      let(:signup) { assigns(:signup) }

      it { should render_template(:new) }
      it { should_not set_the_flash }

      it "doesn't persist the new user in the database" do
        expect(signup.user).to be_nil
      end
    end
  end
end
