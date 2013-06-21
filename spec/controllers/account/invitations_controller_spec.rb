require 'spec_helper'

describe Account::InvitationsController do
  let(:account) { Fabricate(:account) }
  let(:user)    { Fabricate(:user) }
  let(:invitation) { Fabricate(:invitation, account: account) }

  let(:valid_invitation_attributes)   { Fabricate.attributes_for(:invitation) }
  let(:invalid_invitation_attributes) { Fabricate.attributes_for(:invitation, email: "") }

  describe "#permitted_invitation_params" do
    it "permits only name, email and project_ids parameters" do
      valid_invitation_attributes.merge!(project_ids: valid_invitation_attributes[:projects].map(&:id))
      post :create, account_id: account, invitation: valid_invitation_attributes
      expect(subject.send(:permitted_invitation_params).keys).to eq(%w(name email project_ids))
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
        it { should redirect_to(account_invitations_path) }
        it { should set_the_flash }

        it "persists the new invitation in the database" do
          expect(assigns(:invitation)).to be_persisted
        end

        it "sends an invitation email"
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

    describe "#edit" do
      pending
    end

    describe "#update" do
      pending
    end

    describe "#deactivate" do
      pending
    end

    describe "#reactivate" do
      pending
    end

    describe "POST #deliver_mail" do
      before { post :deliver_mail, account_id: account, id: invitation }
      it { should authorize_resource }
      it { should redirect_to(account_invitations_path) }
      it { should set_the_flash }

      it "sends an invitation email"
    end
  end
end
