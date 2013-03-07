require 'spec_helper'

describe Invitations::JoinsController do
  it_should_behave_like "an invitations subcontroller", {
    :new => :get,
    :create => :post
  }
end
