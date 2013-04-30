require 'spec_helper'

describe TwitterAccountsController do
  it { should be_kind_of(ProjectController) }

  it_should_behave_like "an authenticated controller", {
    index: [:get, project_id: 1],
    show: [:get, project_id: 1, id: 1],
    new: [:get, project_id: 1],
    auth: [:post, project_id: 1]
  }

  context "as a project member" do
    let(:user) { Fabricate(:user) }
    let(:account) { Fabricate(:account) }
    let(:membership) { Fabricate(:membership, user: user, account: account) }
    let(:project) { Fabricate(:project, account: account) }
    let!(:permission) { Fabricate(:permission, membership: membership, project: project) }
    let(:twitter_account) { Fabricate(:twitter_account, project: project) }

    before { sign_in user }

    describe "GET #index" do
      before { get :index, project_id: project }
      it { should respond_with(:success) }
      it { should render_template(:index) }
      it { should_not set_the_flash }
    end

    describe "GET #show" do
      before { get :show, project_id: project, id: twitter_account }
      it { should respond_with(:success) }
      it { should render_template(:show) }
      it { should_not set_the_flash }
    end

    describe "GET #new" do
      before { get :new, project_id: project }
      it { should respond_with(:success) }
      it { should render_template(:new) }
      it { should_not set_the_flash }
    end

    describe "POST #auth" do
      context "with params[:auth_scope] = 'read'" do
        before { post :auth, project_id: project, auth_scope: 'read' }

        it { should redirect_to(TwitterAccountsController::AUTH_READ_PATH) }
        it { should_not set_the_flash }

        it "sets the project_id session variable" do
          expect(controller.user_session[:project_id]).to eq(project.id)
        end

        it "sets the twitter_auth_scope session variable" do
          expect(controller.user_session[:twitter_auth_scope]).to eq(:read)
        end
      end

      context "with params[:auth_scope] = 'read_and_write'" do
        before { post :auth, project_id: project, auth_scope: 'read_and_write' }

        it { should redirect_to(TwitterAccountsController::AUTH_READ_AND_WRITE_PATH) }
        it { should_not set_the_flash }

        it "sets the project_id session variable" do
          expect(controller.user_session[:project_id]).to eq(project.id)
        end

        it "sets the twitter_auth_scope session variable" do
          expect(controller.user_session[:twitter_auth_scope]).to eq(:read_and_write)
        end
      end

      context "with params[:auth_scope] = 'direct_messages'" do
        before { post :auth, project_id: project, auth_scope: 'direct_messages' }

        it { should redirect_to(TwitterAccountsController::AUTH_DIRECT_MESSAGES_PATH) }
        it { should_not set_the_flash }

        it "sets the project_id session variable" do
          expect(controller.user_session[:project_id]).to eq(project.id)
        end

        it "sets the twitter_auth_scope session variable" do
          expect(controller.user_session[:twitter_auth_scope]).to eq(:direct_messages)
        end
      end

      context "missing or unknown params[:auth_scope]" do
        before { post :auth, project_id: project }

        it { should redirect_to(project_twitter_accounts_path) }
        it { should set_the_flash.to("Please provide a valid authorization scope.") }

        it "doesn't set the project_id session variable" do
          expect(controller.user_session[:project_id]).to be_nil
        end

        it "doesn't set the twitter_auth_scope session variable" do
          expect(controller.user_session[:twitter_auth_scope]).to be_nil
        end
      end
    end
  end
end
