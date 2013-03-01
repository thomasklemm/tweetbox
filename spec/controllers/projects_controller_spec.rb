require 'spec_helper'

describe ProjectsController do
  describe "#project_params" do
    it "permits only :name" do
      post :create, account_id: 1, project: Fabricate.attributes_for(:project)
      expect(subject.send(:project_params).keys).to eq(%w(name))
    end
  end

  context "an unauthenticated guest" do

    describe "GET #index" do
      before { get :index }
      it { should redirect_to(login_path) }
      it { should set_the_flash }
    end

    describe "GET #show" do
      before { get :show, id: 1 }
      it { should redirect_to(login_path) }
      it { should set_the_flash }
    end

    describe "GET #new" do
      before { get :new, account_id: 1 }
      it { should redirect_to(login_path) }
      it { should set_the_flash }
    end

    describe "GET #edit" do
      before { get :edit, account_id: 1, id: 1 }
      it { should redirect_to(login_path) }
      it { should set_the_flash }
    end

    describe "POST #create" do
      before { post :create, account_id: 1 }
      it { should redirect_to(login_path) }
      it { should set_the_flash }
    end

    describe "PUT #update" do
      before { put :update, account_id: 1, id: 1 }
      it { should redirect_to(login_path) }
      it { should set_the_flash }
    end

    describe "DELETE #destroy" do
      before { delete :destroy, account_id: 1, id: 1 }
      it { should redirect_to(login_path) }
      it { should set_the_flash }
    end

  end
end
