require 'spec_helper'

describe AccountsController do
  it_should_behave_like "an authenticated controller", {
    index: [:get],
    show: [:get, id: 1],
    new: [:get],
    edit: [:get, id: 1],
    create: [:post],
    update: [:put, id: 1],
    destroy: [:delete, id: 1]
  }

  describe "#account_params" do
    it "permits only :name" do
      post :create, account: Fabricate.attributes_for(:account)
      expect(subject.send(:account_params).keys).to eq(%w(name))
    end
  end

  let(:account) { Fabricate(:account) }
  let(:user)    { Fabricate(:user) }
  let(:valid_account_attributes)   { Fabricate.attributes_for(:account) }
  let(:invalid_account_attributes) { Fabricate.attributes_for(:account, name: "") }

  shared_examples "accounts#index for admin and member" do
    before { get :index }
    it { should respond_with(:success) }
    it { should assign_to(:accounts) }
    it { should render_template(:index) }
    it { should_not set_the_flash }
  end

  shared_examples "accounts#show for admin and member" do
    before { get :show, id: account }
    it { should respond_with(:success) }
    it { should assign_to(:account) }
    it { should authorize_resource }
    it { should render_template(:show) }
    it { should_not set_the_flash }
  end

  shared_examples "accounts#new for signed in user" do
    before { get :new }
    it { should respond_with(:success) }
    it { should assign_to(:account) }
    it { should authorize_resource }
    it { should render_template(:new) }
    it { should_not set_the_flash }
  end

  shared_examples "accounts#create for signed in user" do
    context "with valid attributes" do
      before do
        post :create, account: valid_account_attributes
      end

      it { should assign_to(:account) }
      it { should authorize_resource }
      it { should assign_to(:membership) }
      it { should redirect_to(account_path(assigns(:account))) }
      it { should set_the_flash }

      it "assigns the trial plan to the new account" do
        expect(assigns(:account)).to be_trial
      end

      it "creates the new account" do
        expect(assigns(:account)).to be_persisted
      end

      describe "creates account membership" do
        let(:membership) { assigns(:membership) }

        it 'is persisted' do
          expect(membership).to be_persisted
        end

        it "references correct user" do
          expect(membership.user).to eq(user)
        end

        it "references correct account" do
          expect(membership.account).to eq(assigns(:account))
        end

        it "declares user as account admin" do
          expect(membership.user).to be_true
        end
      end

      it "ensures user is admin of new account" do
        expect(user).to be_admin_of(assigns(:account))
      end

      it "ensures user is member of new account" do
        expect(user).to be_member_of(assigns(:account))
      end
    end

    context "with invalid attributes" do
      before do
        post :create, account: invalid_account_attributes
      end

      it { should assign_to(:account) }
      it { should authorize_resource }
      it { should_not assign_to(:membership) }
      it { should render_template(:new) }
      it { should_not set_the_flash }

      it "does not persist the new account" do
        expect(assigns(:account)).not_to be_persisted
      end
    end
  end

  context "admin access" do
    before do
      Fabricate(:membership, user: user, account: account, admin: true)
      sign_in user
    end

    it "assignes admin to current_user" do
      expect(subject.current_user).to eq(user)
    end

    describe "GET #index" do
      it_should_behave_like "accounts#index for admin and member"
    end

    describe "GET #show" do
      it_should_behave_like "accounts#show for admin and member"
    end

    describe "GET #new" do
      it_should_behave_like "accounts#new for signed in user"
    end

    describe "POST #create" do
      it_should_behave_like "accounts#create for signed in user"
    end

    describe "GET #edit" do
      before { get :edit, id: account }
      it { should respond_with(:success) }
      it { should assign_to(:account) }
      it { should authorize_resource }
      it { should render_template(:edit) }
      it { should_not set_the_flash }
    end

    describe "PUT #update" do
      context "with valid attributes" do
        before do
          put :update, id: account, account: valid_account_attributes
        end

        it { should assign_to(:account) }
        it { should authorize_resource }
        it { should redirect_to(account_path(assigns(:account)))}
        it { should set_the_flash }

        it 'saves the new attributes' do
          expect(assigns(:account).reload.name).to eq(valid_account_attributes[:name])
        end
      end

      context "with invalid attributes" do
        before do
          put :update, id: account, account: invalid_account_attributes
        end

        it { should assign_to(:account) }
        it { should authorize_resource }
        it { should render_template(:edit) }
        it { should_not set_the_flash }

        it 'does not save the new attributes' do
          expect(assigns(:account).reload.name).to_not eq(invalid_account_attributes[:name])
        end
      end
    end

    describe "DELETE #destroy" do
      context "account without associated projects" do
        before { delete :destroy, id: account }

        it { should assign_to(:account) }
        it { should authorize_resource }
        it { should redirect_to(accounts_path) }
        it { should set_the_flash }

        it 'destroys the account' do
          expect(assigns(:account)).to be_destroyed
        end
      end

      context "account with associated projects" do
        before do
          Fabricate(:project, account: account)
          delete :destroy, id: account
        end

        it { should assign_to(:account) }
        it { should authorize_resource }
        it { should redirect_to(account_path(assigns(:account))) }
        it { should set_the_flash }

        it 'does not destroy the account' do
          expect(assigns(:account)).to be_persisted
        end
      end
    end
  end

  context "member access" do
    before do
      Fabricate(:membership, user: user, account: account, admin: false)
      sign_in user
    end

    describe "GET #index" do
      it_should_behave_like "accounts#index for admin and member"
    end

    describe "GET #show" do
      it_should_behave_like "accounts#show for admin and member"
    end

    describe "GET #new" do
      it_should_behave_like "accounts#new for signed in user"
    end

    describe "POST #create" do
      it_should_behave_like "accounts#create for signed in user"
    end

    describe "GET #edit" do
      let(:forbidden_request) { get :edit, id: account }
      it_should_behave_like "a forbidden request"
    end

    describe "PUT #update" do
      let(:forbidden_request) { put :update, id: account, account: valid_account_attributes }
      it_should_behave_like "a forbidden request"
    end

    describe "DELETE #destroy" do
      let(:forbidden_request) { delete :destroy, id: account }
      it_should_behave_like "a forbidden request"
    end
  end
end
