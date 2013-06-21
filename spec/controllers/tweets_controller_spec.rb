require 'spec_helper'

describe TweetsController do
  it { should be_a ProjectController }

  context "project member access" do
    let!(:user)    { Fabricate(:user) }
    let!(:project) { Fabricate(:project) }
    let!(:membership) { Fabricate(:membership, user: user, account: project.account) }
    let!(:permission) { Fabricate(:permission, membership: membership, project: project)  }

    before do
      sign_in user
    end

    describe "GET #index" do

      context "requesting :new tweets" do
        before do
          get :index, project_id: project, workflow: :new
        end
        it { should respond_with(:success) }
        it { should render_template(:index) }
        it { should_not set_the_flash }
      end

        pending "retrieves tweets with workflow_status :new" do
          project.expects(:tweets).returns(
            mock do
              expects(:where).returns(true)
            end
          )

          get :index, project_id: project, workflow: :new
        end

      context "requesting :new tweets without workflow param" do
        before { get :index, project_id: project}
        it { should respond_with(:success) }
        it { should render_template(:index) }
        it { should_not set_the_flash }

        it "retrieves tweets with workflow_status :new" do
          Fabricate(:tweet, project: project, workflow_state: :new)
          Fabricate(:tweet, project: project, workflow_state: :open)
          get :index, project_id: project, workflow: :new

          expect(assigns(:tweets).map(&:current_state).uniq).to eq([:new])
          expect(assigns(:tweets).size).to eq(1)
        end
      end

      context "requesting :open tweets" do
        before { get :index, project_id: project, workflow: :open }
        it { should respond_with(:success) }
        it { should render_template(:index) }
        it { should_not set_the_flash }

        it "retrieves tweets with workflow_status :new" do
          Fabricate(:tweet, project: project, workflow_state: :open)
          Fabricate(:tweet, project: project, workflow_state: :new)
          get :index, project_id: project, workflow: :open

          expect(assigns(:tweets).map(&:current_state).uniq).to eq([:open])
          expect(assigns(:tweets).size).to eq(1)
        end
      end

      context "requesting :closed tweets" do
        before { get :index, project_id: project, workflow: :closed }
        it { should respond_with(:success) }
        it { should render_template(:index) }
        it { should_not set_the_flash }

        pending "retrieves tweets with workflow_status :new" do
          Fabricate(:tweet, project: project, workflow_state: :new)

          expect(assigns(:tweets).map(&:current_state).uniq).to eq([:closed])
          expect(assigns(:tweets).size).to eq(1)
        end
      end

    end
  end
end
