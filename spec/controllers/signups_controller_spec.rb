require 'spec_helper'

describe SignupsController do

  describe "GET #new" do
    before { get :new }
    it { should respond_with(:success) }
    it { should render_template(:new) }
    it { should_not set_the_flash }
  end

  let(:valid_signup_attributes)   { Fabricate.attributes_for(:signup) }
  let(:invalid_signup_attributes) { Fabricate.attributes_for(:signup, first_name: '', last_name: '') }

  describe "POST #create" do
    context "with valid attributes" do
      before { post :create, signup: valid_signup_attributes }
      let(:signup) { assigns(:signup) }

      it { should redirect_to(projects_path) }
      it { should set_the_flash }

      it "persists the user" do
        expect(signup.user).to be_persisted
      end

      it "persists the account" do
        expect(signup.account).to be_persisted
      end

      it "signs the user in" do
        expect(controller.current_user).to eq(signup.user)
      end
    end

    context "with invalid attributes" do
      before { post :create, signup: invalid_signup_attributes }
      let(:signup) { assigns(:signup) }

      it { should render_template(:new) }
      it { should_not set_the_flash }

      it "does not persist the user" do
        expect(signup.user).to be_nil
      end

      it "does not persist the account" do
        expect(signup.account).to be_nil
      end
    end
  end

end
