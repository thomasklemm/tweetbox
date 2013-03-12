require 'spec_helper'

describe ApplicationController do

  describe "helper methods" do
    let!(:user)       { Fabricate(:user) }
    let!(:account)    { Fabricate(:account) }
    let!(:membership) { Fabricate(:membership, user: user, account: account, admin: true) }
    let!(:project)    { Fabricate(:project, account: account) }

    let!(:second_account)    { Fabricate(:account) }
    let!(:second_membership) { Fabricate(:membership, user: user, account: second_account, admin: false) }
    let!(:second_project)    { Fabricate(:project, account: second_account) }
    let!(:second_permission) { Fabricate(:permission, membership: second_membership, project: second_project) }

    let!(:other_account) { Fabricate(:account) }
    let!(:other_project) { Fabricate(:project, account: other_account) }

    before do
      sign_in user
    end

    describe "#user_accounts" do
      it "returns the user's accounts" do
        expect(controller.send(:user_accounts)).to eq([account, second_account])
      end
    end

    describe "#user_account" do
      context "with a valid id in params[:id]" do
        it "returns record" do
          controller.params[:id] = account.id
          expect(controller.send(:user_account)).to eq(account)
        end
      end

      context "with a valid id in params[:account_id]" do
        it "returns record" do
          controller.params[:account_id] = account.id
          expect(controller.send(:user_account)).to eq(account)
        end
      end

      context "with different ids in both params[:account_id] and params[:id]" do
        it "returns record with id of params[:account_id]" do
          controller.params[:account_id] = account.id
          controller.params[:id] = second_account.id
          expect(controller.send(:user_account)).to eq(account)
        end
      end

      context "with an invalid id" do
        it "raises record not found error" do
          controller.params[:account_id] = other_account.id
          expect { controller.send(:user_account) }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    describe "#user_projects" do
      it "returns the user's projects" do
        expect(controller.send(:user_projects)).to eq([project, second_project])
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

      context "with a valid id in user_session[:project_id]" do
        it "returns record" do
          controller.user_session[:project_id] = project.id
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

      context "with different ids in both user_session[:project_id] and params[:id]" do
        it "returns record with id of user_session[:project_id]" do
          controller.user_session[:project_id] = project.id
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

end
