require "spec_helper"

describe SalesTweetsController do
  describe "routing" do

    it "routes to #index" do
      get("/sales_tweets").should route_to("sales_tweets#index")
    end

    it "routes to #new" do
      get("/sales_tweets/new").should route_to("sales_tweets#new")
    end

    it "routes to #show" do
      get("/sales_tweets/1").should route_to("sales_tweets#show", :id => "1")
    end

    it "routes to #edit" do
      get("/sales_tweets/1/edit").should route_to("sales_tweets#edit", :id => "1")
    end

    it "routes to #create" do
      post("/sales_tweets").should route_to("sales_tweets#create")
    end

    it "routes to #update" do
      put("/sales_tweets/1").should route_to("sales_tweets#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/sales_tweets/1").should route_to("sales_tweets#destroy", :id => "1")
    end

  end
end
