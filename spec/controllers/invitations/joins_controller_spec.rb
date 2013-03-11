require 'spec_helper'

describe Invitations::JoinsController do
  it_should_behave_like "an invitations subcontroller", {
    :new => :get,
    :create => :post
  }

  let(:invitation) { Fabricate(:invitation) }
  let(:user)       { Fabricate(:user) }

  let(:valid_join_params) { Fabricate(:invitation_join, invitation: invitation, user: user) }

  describe "GET #new" do
    before { get :new, code: invitation }
    it { should respond_with(:success) }
    it { should assign_to(:join) }
    it { should render_template(:new) }
    it { should_not set_the_flash }

    let(:join) { assigns(:join) }

    it "associates the matching invitation" do
      expect(join.invitation).to eq(invitation)
    end

    it "associates the current user" do
      expect(join.user).to eq(subject.current_user)
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

      let(:join) { assigns(:join) }

      it "creates the membership" do
        expect(user).to be_member_of(invitation.account)
      end
    end
  end
end
