require 'spec_helper'

describe ApplicationController do
  let!(:user)       { Fabricate(:user) }
  let!(:account)    { Fabricate(:account) }
  let!(:membership) { Fabricate(:membership, user: user, account: account, admin: true) }
  let!(:project)    { Fabricate(:project, account: account) }
  let!(:permission) { Fabricate(:permission, user: user, project: project) }

  let(:other_account) { Fabricate(:account) }
  let(:other_project) { Fabricate(:project, account: other_account) }

  before do
    sign_in user
  end

  describe "helper methods" do
    describe "#user_account" do
      it "returns the account the user is a member of" do
        expect(controller.send(:user_account)).to eq(account)
      end
    end

    describe "#user_projects" do
      it "returns the user's projects" do
        expect(controller.send(:user_projects)).to eq([project])
      end
    end

    describe "#user_project" do
      context "with a valid id in params[:id]" do
        it "returns record" do
          controller.params[:id] = project.id
          expect(controller.send(:user_project)).to eq(project)
        end
      end

      context "with a valid id in params[:project_id]" do
        it "returns record" do
          controller.params[:project_id] = project.id
          expect(controller.send(:user_project)).to eq(project)
        end
      end

      context "with different ids in both params[:project_id] and params[:id]" do
        it "returns record with id of params[:project_id]" do
          controller.params[:project_id] = project.id
          controller.params[:id] = other_project.id
          expect(controller.send(:user_project)).to eq(project)
        end
      end

      context "with an invalid id" do
        it "raises record not found error" do
          controller.params[:project_id] = other_project.id
          expect { controller.send(:user_project) }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end

  describe "#current_user" do
    it "returns the decorated current_user" do
      expect(controller.current_user).to be_present
      expect(controller.current_user).to be_decorated
    end
  end
end
