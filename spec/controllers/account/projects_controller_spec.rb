require 'spec_helper'

describe Account::ProjectsController do

  describe "GET 'index'" do
    it "returns http success" do
      get 'index'
      response.should be_success
    end
  end

  describe "GET 'new'" do
    it "returns http success" do
      get 'new'
      response.should be_success
    end
  end

  describe "GET 'create'" do
    it "returns http success" do
      get 'create'
      response.should be_success
    end
  end

  describe "GET 'edit'" do
    it "returns http success" do
      get 'edit'
      response.should be_success
    end
  end

  describe "GET 'update'" do
    it "returns http success" do
      get 'update'
      response.should be_success
    end
  end

  describe "GET 'deactivate'" do
    it "returns http success" do
      get 'deactivate'
      response.should be_success
    end
  end

  describe "GET 'reactivate'" do
    it "returns http success" do
      get 'reactivate'
      response.should be_success
    end
  end

end
