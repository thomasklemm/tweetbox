require 'spec_helper'

describe InvitesController do
  let(:user)     { Fabricate(:user) }
  let(:account)    { Fabricate(:account) }
  let(:membership) { Fabricate(:membership, user: user, account: account, admin: true) }
  let(:projects)   { [ Fabricate(:project, account: account), Fabricate(:project, account: account) ] }
  let(:invitation) { Fabricate(:invitation, account: account, sender: user, admin: false) }

  describe "GET #show", "valid invite code" do
    before { get :show, id: invitation }
    it { should respond_with(:success) }
    it { should assign_to(:invitation) }
    it { should render_template(:show) }
    it { should_not set_the_flash }
  end

  describe "GET #show", "invalid invite code" do
    it "raises record not found error" do
      expect { get :show, id: 123 }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
