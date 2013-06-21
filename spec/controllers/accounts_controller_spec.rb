require 'spec_helper'

describe AccountsController do
  describe "#account_params" do
    it "permits only :name" do
      put :update, id: 1, account: valid_account_attributes
      expect(subject.send(:account_params).keys).to eq(%w(name))
    end
  end

  let(:account) { Fabricate(:account) }
  let(:user)    { Fabricate(:user) }
  let(:valid_account_attributes)   { Fabricate.attributes_for(:account) }
  let(:invalid_account_attributes) { Fabricate.attributes_for(:account, name: "") }

  context "account admin" do
    before do
      Fabricate(:membership, user: user, account: account, admin: true)
      sign_in user
    end

    describe "GET #show" do
      before { get :show }
      it { should redirect_to(account_projects_path) }
    end

    describe "GET #edit" do
      before { get :edit, id: account }
      it { should respond_with(:success) }
      it { should authorize_resource }
      it { should render_template(:edit) }
      it { should_not set_the_flash }
    end

    describe "PUT #update" do
      context "with valid attributes" do
        before do
          put :update, id: account, account: valid_account_attributes
        end

        it { should authorize_resource }
        it { should redirect_to(account_path) }
        it { should set_the_flash }

        it 'saves the new attributes' do
          expect(assigns(:account).reload.name).to eq(valid_account_attributes[:name])
        end
      end

      context "with invalid attributes" do
        before do
          put :update, id: account, account: invalid_account_attributes
        end

        it { should authorize_resource }
        it { should render_template(:edit) }
        it { should_not set_the_flash }

        it 'does not save the new attributes' do
          expect(assigns(:account).reload.name).to_not eq(invalid_account_attributes[:name])
        end
      end
    end
  end
end
