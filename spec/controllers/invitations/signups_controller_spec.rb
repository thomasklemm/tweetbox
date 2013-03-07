require 'spec_helper'

describe Invitations::SignupsController do
  it_should_behave_like "an invitations subcontroller", {
    :new => :get,
    :create => :post
  }

  describe "GET #new" do

  end

  describe "POST #create" do

  end
end
