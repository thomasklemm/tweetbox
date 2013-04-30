require 'spec_helper'

describe ProjectController do

  controller do
    def show
      render text: '42'
    end
  end

  describe "redirects guest user to login" do
    before { get :show, id: 1 }

    it { should redirect_to(login_path) }
    it { should set_the_flash.to("You need to sign in or sign up before continuing.") }
  end

  describe "grants access to project members" do
    let!(:user)    { Fabricate(:user) }
    let!(:project) { Fabricate(:project) }
    let!(:membership) { Fabricate(:membership, user: user, account: project.account) }
    let!(:permission) { Fabricate(:permission, membership: membership, project: project)  }

    before do
      sign_in user
      get :show, id: project
    end

    it "verfies the user is signed in" do
      expect(controller.current_user).to eq(user)
    end

    it "loads the project" do
      expect(assigns(:project)).to eq(project)
    end

    it { should authorize_resource }
  end

  describe "forbids access if user has no permissions on the project" do
    let!(:user)    { Fabricate(:user) }
    let!(:project) { Fabricate(:project) }
    let!(:membership) { Fabricate(:membership, user: user, account: project.account) }

    before do
      sign_in user
    end

    it "raises a record not found error" do
      expect { get :show, id: project }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end




# end
