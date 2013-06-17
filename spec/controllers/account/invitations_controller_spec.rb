require 'spec_helper'

describe Account::InvitationsController do
  let(:account) { Fabricate(:account) }
  let(:user)    { Fabricate(:user) }
  let(:invitation) { Fabricate(:invitation, account: account) }

  let(:valid_invitation_attributes)   { Fabricate.attributes_for(:invitation) }
  let(:invalid_invitation_attributes) { Fabricate.attributes_for(:invitation, email: "") }

  describe "#invitation_params" do
    it "permits only name, email and project_ids parameters" do
      post :create, account_id: account, invitation: valid_invitation_attributes
      expect(subject.send(:invitation_params).keys).to eq(%w(email admin project_ids))
    end
  end

  context "account admin access" do
    before do
      Fabricate(:membership, user: user, account: account, admin: true)
      sign_in user
    end

    describe "GET #index" do
      before { get :index, account_id: account }
      it { should respond_with(:success) }
      it { should authorize_resource }
      it { should render_template(:index) }
      it { should_not set_the_flash }
    end

    describe "GET #new" do
      before { get :new, account_id: account }
      it { should respond_with(:success) }
      it { should authorize_resource }
      it { should render_template(:new) }
      it { should_not set_the_flash }
    end

    describe "POST #create" do
      context "with valid attributes" do
        before { post :create, account_id: account, invitation: valid_invitation_attributes }
        it { should authorize_resource }
        it { should redirect_to(account_invitations_path(account)) }
        it { should set_the_flash }

        it "persists the new invitation in the database" do
          expect(assigns(:invitation)).to be_persisted
        end

        it "sends an invitation email" do
          expect(assigns(:sent_mail)).to be_true
        end
      end

      context "with invalid attributes" do
        before { post :create, account_id: account, invitation: invalid_invitation_attributes }
        it { should authorize_resource }
        it { should render_template(:new) }
        it { should_not set_the_flash }

        it "doesn't persist the new invitation" do
          expect(assigns(:invitation)).to be_new_record
        end

        it "doesn't send an invitation email" do
          expect(assigns(:sent_mail)).to be_nil
        end
      end
    end

    describe "DELETE #destroy" do
      before { delete :destroy, account_id: account, id: invitation }
      it { should authorize_resource }
      it { should redirect_to(account_invitations_path(account)) }
      it { should set_the_flash }

      it "destroys the invitation" do
        expect(assigns(:invitation)).to be_destroyed
      end
    end

    describe "PUT #send_mail" do
      before { put :send_mail, account_id: account, id: invitation }
      it { should authorize_resource }
      it { should redirect_to(account_invitations_path(account)) }
      it { should set_the_flash }

      it "sends an invitation email" do
        expect(assigns(:sent_mail)).to be_true
      end
    end
  end
end
