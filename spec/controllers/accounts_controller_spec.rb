require 'spec_helper'

describe AccountsController do
  describe "#account_params" do
    it "permits only :name" do
      post :create, account: Fabricate.attributes_for(:account)
      expect(subject.send(:account_params).keys).to eq(%w(name))
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
      before { get :new }
      it { should redirect_to(login_path) }
      it { should set_the_flash }
    end

    describe "GET #edit" do
      before { get :edit, id: 1 }
      it { should redirect_to(login_path) }
      it { should set_the_flash }
    end

    describe "POST #create" do
      before { post :create }
      it { should redirect_to(login_path) }
      it { should set_the_flash }
    end

    describe "PUT #update" do
      before { put :update, id: 1 }
      it { should redirect_to(login_path) }
      it { should set_the_flash }
    end

    describe "DELETE #destroy" do
      before { delete :destroy, id: 1 }
      it { should redirect_to(login_path) }
      it { should set_the_flash }
    end

  end

end

describe AccountsController, "GET #index" do
  # it_behaves_like "an authenticated action"
  # before { get :index }

  # it { should assign_to(:accounts) }
  # it { should respond_with(:success) }
  # it { should render_template(:index) }
  # it { should_not set_the_flash }
end

# describe AccountsController, "GET #show" do
#   before { get :show, id: Fabricate(:account) }
# end

describe AccountsController, "GET #new" do

end

describe AccountsController, "GET #edit" do

end

describe AccountsController, "POST #create" do

end

describe AccountsController, "PUT #update" do

end

describe AccountsController, "DELETE #destroy" do

end

# describe AccountsController do
#   describe ".before_filters" do
#     it "authenticates user" do
#       expect(AccountsController.before_filters).to include(:authenticate_user!)
#     end
#   end

#   describe ".after_filters" do
#     it "verifies authorization has happened"
#   end

#   describe "member access" do

#   end

#   describe "admin access" do

#   end

#   describe ""

#   describe "GET #index" do
#     it "assigns the user's accounts to @accounts"
#     it "renders the :index view" do
#       expect(response).to render_template(:index)
#     end
#   end

#   describe "GET #show" do
#     it "assigns the requested account to @account"
#     it "authorizes @account"
#     it "renders the :show template" do
#       expect(response).to render_template(:show)
#     end
#   end

#   describe "GET #new" do
#     it "assigns a new Account to @account"
#     it "authorizes @account"
#     it "renders the :new template" do
#       expect(response).to render_template(:new)
#     end
#   end

#   describe "GET #edit" do
#     it "assigns the requested account to @account"
#     it "authorizes @account"
#     it "renders the :edit template" do
#       expect(response).to render_template(:edit)
#     end
#   end

#   describe "POST #create" do
#     context "with valid attributes" do
#       it "authorizes @account"
#       it "saves the new account in the database"
#       it "redirect to the new account"
#     end

#     context "with invalid attributes" do
#       it "authorizes @account"
#       it "does not save the new account in the database"
#       it "re-renders the :new template"
#     end
#   end

#   describe "PUT #update" do
#     context "with valid attributes" do
#       it "authorizes @account"
#       it "updates the account in the database"
#       it "redirects to the account"
#     end

#     context "with invalid attributes" do
#       it "authorizes @account"
#       it "does not update the account in the database"
#       it "re-renders the :edit template"
#     end
#   end

#   describe "DELETE #destroy" do
#     it "assigns the requested account to @account"
#     it "authorizes @account"
#     it "deletes the account from the database"
#     it "redirects to the accounts page"
#   end
# end

  # describe "GET 'index'" do
  #   it "returns http success" do

  #   end
  # end

  # describe "GET 'show'" do
  #   it "returns http success" do
  #     get 'show'
  #     response.should be_success
  #   end
  # end

  # describe "GET 'new'" do
  #   it "returns http success" do
  #     get 'new'
  #     response.should be_success
  #   end
  # end

  # describe "GET 'create'" do
  #   it "returns http success" do
  #     get 'create'
  #     response.should be_success
  #   end
  # end

  # describe "GET 'edit'" do
  #   it "returns http success" do
  #     get 'edit'
  #     response.should be_success
  #   end
  # end

  # describe "GET 'update'" do
  #   it "returns http success" do
  #     get 'update'
  #     response.should be_success
  #   end
  # end

  # describe "GET 'destroy'" do
  #   it "returns http success" do
  #     get 'destroy'
  #     response.should be_success
  #   end
  # end
