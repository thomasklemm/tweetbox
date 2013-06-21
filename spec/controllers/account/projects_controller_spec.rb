require 'spec_helper'

require 'spec_helper'

describe Account::ProjectsController do
  it { should be_an AccountController }

  describe "#project_params" do
    it "permits only :name" do
      post :create, account_id: 1, project: Fabricate.attributes_for(:project).merge(user_ids: [])
      expect(subject.send(:project_params).keys).to eq(%w(name user_ids))
    end
  end

  let!(:user)    { Fabricate(:user) }
  let!(:account) { Fabricate(:account) }
  let!(:membership) { Fabricate(:membership, user: user, account: account, admin: true)  }
  let!(:project)    { Fabricate(:project, account: account) }
  let!(:permission) { Fabricate(:permission, user: user, project: project) }

  let(:valid_project_attributes)   { Fabricate.attributes_for(:project) }
  let(:invalid_project_attributes) { Fabricate.attributes_for(:project, name: "") }

  before do
    sign_in user
  end

  describe "GET #index" do
    before { get :index }
    it { should respond_with(:success) }
    it { should render_template(:index) }
    it { should_not set_the_flash }
  end

  describe "GET #new" do
    before { get :new, account_id: account }
    it { should respond_with(:success) }
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
      it { should authorize_resource }
      it { should redirect_to(account_projects_path) }
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
    it { should authorize_resource }
    it { should render_template(:new) }
    it { should_not set_the_flash }
  end

  describe "PUT #update" do
    context "with valid attributes" do
      before { put :update, account_id: account, id: project, project: valid_project_attributes }
      it { should authorize_resource }
      it { should redirect_to(account_projects_path) }
      it { should set_the_flash }

      it "persists the updated project attributes in the database" do
        expect(assigns(:project).reload.name).to eq(valid_project_attributes[:name])
      end
    end

    context "with invalid attributes" do
      before { put :update, account_id: account, id: project, project: invalid_project_attributes }
      it { should authorize_resource }
      it { should render_template(:edit) }
      it { should_not set_the_flash }

      it "doesn't persist the updated project attributes in the database" do\
        name = assigns(:project).reload.name
        expect(name).to eq(project.name)
        expect(name).to_not eq(invalid_project_attributes[:name])
      end
    end
  end

end

