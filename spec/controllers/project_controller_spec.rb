require 'spec_helper'

describe ProjectController do
  controller do
    def test
      render text: "42"
    end
  end

  def with_test_routing
    with_routing do |map|
      map.draw do
        get "test" => "anonymous#test"
        get "login" => "devise/sessions#new", as: :login
      end
      yield
    end
  end

  context "unauthenticated user" do
    before do
      with_test_routing do
        get :test
      end
    end

    it { should redirect_to(login_path) }
    it { should set_the_flash }
    its(:current_user) { should be_blank }
  end

  context "project member access" do
    let(:user)        { Fabricate(:user) }
    let(:account)     { Fabricate(:account) }
    let(:membership)  { Fabricate(:membership, user: user, account: account) }
    let(:project)     { Fabricate(:project, account: account) }
    let!(:permission) { Fabricate(:permission, membership: membership, project: project) }

    before do
      sign_in user

      with_test_routing do
        get :test
      end
    end

    it { should respond_with(:success) }
    it { should assign_to(:project) }
    it { should authorize_resource }
  end
end

# be_a_kind_of(ProjectController)
