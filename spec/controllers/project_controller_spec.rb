require 'spec_helper'

class ProjectSubController < ProjectController
  def show
    render text: '42'
  end

  def login
    render text: 'login_path'
  end
end

describe ProjectSubController do
  it { should be_a_kind_of(ProjectController) }

  def with_test_routing
    with_routing do |map|
      map.draw do
        match "test_route" => "project_sub#show"
        match "login" => "project_sub#login", as: :login
      end
      yield
    end
  end

  context "guest user is trying to access" do
    describe "requires user to sign in" do

      it "redirects to login path" do
        with_test_routing do
          get :show, id: 1
          should redirect_to(login_path)
        end
      end

      it "sets the flash" do
        with_test_routing do
          get :show, id: 1
          should set_the_flash
        end
      end

      it "does not set or have the current user" do
        with_test_routing do
          get :show, id: 1
          expect(controller.current_user).to be_nil
        end
      end

    end
  end

  describe "grants access to project member" do
    let!(:user)    { Fabricate(:user) }
    let!(:project) { Fabricate(:project) }
    let!(:membership) { Fabricate(:membership, user: user, account: project.account) }
    let!(:permission) { Fabricate(:permission, membership: membership, project: project)  }

    before do
      sign_in user
    end

    it "ensures that user is signed in" do
      with_test_routing do
        get :show, id: project
        expect(controller.current_user).to eq(user)
      end
    end

    it "loads the project" do
      with_test_routing do
        get :show, id: project
        expect(assigns(:project)).to eq(project)
      end
    end

    it "authorizes the resource" do
      with_test_routing do
        get :show, id: project
        should authorize_resource
      end
    end
  end

  describe "forbids access for non-project account member" do
    let!(:user)    { Fabricate(:user) }
    let!(:project) { Fabricate(:project) }
    let!(:membership) { Fabricate(:membership, user: user, account: project.account) }

    before do
      sign_in user
    end

    it "raises a record not found error" do
      with_test_routing do
        expect { get :show, id: project }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

end
