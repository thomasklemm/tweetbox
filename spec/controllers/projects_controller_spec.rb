require 'spec_helper'

describe ProjectsController do
  describe "#project_params" do
    it "permits only :name" do
      post :create, account_id: 1, project: Fabricate.attributes_for(:project)
      expect(subject.send(:project_params).keys).to eq(%w(name))
    end
  end

  let(:user)    { Fabricate(:user) }
  let(:account) { Fabricate(:account) }
  let(:account_membership) { Fabricate(:membership, user: user, account: account, admin: false)  }
  let(:admin_account_membership) { Fabricate(:membership, user: user, account: account, admin: true) }
  let(:project) { Fabricate(:project, account: account) }
  let(:permission) { Fabricate(:permission, membership: account_membership, project: project) }

  let(:valid_project_attributes)   { Fabricate.attributes_for(:project) }
  let(:invalid_project_attributes) { Fabricate.attributes_for(:project, name: '') }

  shared_examples "projects#index for account admin and project member" do
    before { get :index }
    it { should respond_with(:success) }
    it { should assign_to(:projects) }
    it { should render_template(:index) }
    it { should_not set_the_flash }
  end

  shared_examples "projects#show for account admin and project member" do
    before { get :show, id: project }
    it { should respond_with(:success) }
    it { should assign_to(:project) }
    it { should authorize_resource }
    it { should render_template(:show) }
    it { should_not set_the_flash }
  end

  context "account admin access" do
    before do
      admin_account_membership
      project

      sign_in user
    end

    describe "GET #index" do
      it_should_behave_like "projects#index for account admin and project member"
    end

    describe "GET #show" do
      it_should_behave_like "projects#show for account admin and project member"
    end

    describe "GET #new" do
      before { get :new, account_id: account }
      it { should respond_with(:success) }
      it { should assign_to(:project) }
      it { should authorize_resource }
      it { should render_template(:new) }
      it { should_not set_the_flash }

      it "builds the new project through account" do
        expect(assigns(:project).account).to eq(account)
      end
    end

    describe "POST #create" do
      context "with valid attributes" do
        before { post :create, account_id: account, project: valid_project_attributes }
        it { should assign_to(:project) }
        it { should authorize_resource }
        it { should redirect_to(project_path(assigns(:project))) }
        it { should set_the_flash }

        it "builds the new project through account" do
          expect(assigns(:project).account).to eq(account)
        end

        it "persists the new project in the database" do
          expect(assigns(:project)).to be_persisted
        end
      end

      context "with invalid attributes" do
        before { post :create, account_id: account, project: invalid_project_attributes }
        it { should assign_to(:project) }
        it { should authorize_resource }
        it { should render_template(:new) }
        it { should_not set_the_flash }

        it "builds the new project through account" do
          expect(assigns(:project).account).to eq(account)
        end

        it "doesn't persist the new project in the database" do
          expect(assigns(:project)).to be_new_record
        end
      end
    end

    describe "GET #edit" do
      before { get :new, account_id: account, id: project }
      it { should respond_with(:success) }
      it { should assign_to(:project) }
      it { should authorize_resource }
      it { should render_template(:new) }
      it { should_not set_the_flash }
    end

    describe "PUT #update" do
      context "with valid attributes" do
        before { put :update, account_id: account, id: project, project: valid_project_attributes }
        it { should assign_to(:project) }
        it { should authorize_resource }
        it { should redirect_to(project_path(assigns(:project))) }
        it { should set_the_flash }

        it "persists the updated project attributes in the database" do
          expect(assigns(:project).reload.name).to eq(valid_project_attributes[:name])
        end
      end

      context "with invalid attributes" do
        before { put :update, account_id: account, id: project, project: invalid_project_attributes }
        it { should assign_to(:project) }
        it { should authorize_resource }
        it { should render_template(:edit) }
        it { should_not set_the_flash }

        it "doesn't persist the updated project attributes in the database" do
          expect(assigns(:project).reload.name).to eq(project.name)
          expect(assigns(:project).reload.name).to_not eq(invalid_project_attributes[:name])
        end
      end
    end

    describe "DELETE #destroy" do
      before { delete :destroy, account_id: account, id: project }
      it { should assign_to(:project) }
      it { should authorize_resource }
      it { should redirect_to(account_path(account)) }
      it { should set_the_flash }
    end
  end

  context "project member access" do
    before do
      account_membership
      project
      permission

      sign_in user
    end

    describe "GET #index" do
      it_should_behave_like "projects#index for account admin and project member"
    end

    describe "GET #show" do
      it_should_behave_like "projects#show for account admin and project member"
    end

    describe "GET #new" do
      let(:forbidden_request) { get :new, account_id: account }
      it_should_behave_like "a forbidden request"
    end

    describe "POST #create" do
      let(:forbidden_request) { post :create, account_id: account, project: valid_project_attributes }
      it_should_behave_like "a forbidden request"
    end

    describe "GET #edit" do
      let(:forbidden_request) { get :edit, account_id: account, id: project }
      it_should_behave_like "a forbidden request"
    end

    describe "PUT #update" do
      let(:forbidden_request) { put :update, account_id: account, id: project, project: valid_project_attributes }
      it_should_behave_like "a forbidden request"
    end

    describe "DELETE #destroy" do
      let(:forbidden_request) { delete :destroy, account_id: account, id: project }
      it_should_behave_like "a forbidden request"
    end
  end
end

describe ProjectsController do
  context "unauthenticated guest trying to access" do
    describe "GET #index" do
      before { get :index }
      it_should_behave_like "an authenticated request"
    end

    describe "GET #show" do
      before { get :show, id: 1 }
      it_should_behave_like "an authenticated request"
    end

    describe "GET #new" do
      before { get :new, account_id: 1 }
      it_should_behave_like "an authenticated request"
    end

    describe "GET #edit" do
      before { get :edit, account_id: 1, id: 1 }
      it_should_behave_like "an authenticated request"
    end

    describe "POST #create" do
      before { post :create, account_id: 1 }
      it_should_behave_like "an authenticated request"
    end

    describe "PUT #update" do
      before { put :update, account_id: 1, id: 1 }
      it_should_behave_like "an authenticated request"
    end

    describe "DELETE #destroy" do
      before { delete :destroy, account_id: 1, id: 1 }
      it_should_behave_like "an authenticated request"
    end
  end
end
