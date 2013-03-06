require 'spec_helper'

describe InvitationSignupsController do
  describe "GET #new" do
    context "with valid code" do
      let(:invitation) { Fabricate(:invitation) }
      before { get :new, code: invitation.code }

      it { should respond_with(:success) }
      it { should assign_to(:signup) }
      it { should_not set_the_flash }

      it "assigns the right invitation" do
        expect(assigns(:signup).invitation).to eq(invitation)
      end
    end

    context "with invalid code" do
      context "without any code provided" do
        before { get :new }
        it { should redirect_to(root_path) }
        it { should set_the_flash.to('Please provide a valid invitation code.') }
      end

      context "with non-existing code" do
        before { get :new, code: '123' }
        it { should redirect_to(root_path) }
        it { should set_the_flash.to('Please provide a valid invitation code.') }
      end

      context "with code that has been used already" do
        let!(:invitation) { Fabricate(:invitation, used: true) }
        before { get :new, code: invitation.code }
        it { should redirect_to(root_path) }
        it { should set_the_flash.to('Your invitation code has already been used.') }
      end
    end
  end

  # New user
  describe "POST #create" do
    context "with valid attributes" do
      let(:valid_attributes) { Fabricate.attributes_for(:invitation_signup_with_new_user) }
      before { post :create, signup: valid_attributes }
      let(:signup) { assigns(:signup) }

      it { should redirect_to(projects_path) }
      it { should assign_to(:signup) }
      it { should set_the_flash }

      describe "@signup" do
        subject { signup }

        its(:user) { should be_persisted }
        its(:membership) { should be_persisted }

        it "marks invitation as used" do
          expect(subject.invitation).to be_used
        end
      end

      it "signs the created user in" do
        expect(signup.user).to eq(subject.current_user)
      end
    end

    context "with invalid attributes" do
      let(:invalid_attributes) { Fabricate.attributes_for(:invitation_signup_with_new_user, name: '') }
      before { post :create, signup: invalid_attributes }
      let(:signup) { assigns(:signup) }

      it { should_not redirect_to(projects_path) }
      it { should assign_to(:signup) }
      it { should_not set_the_flash }

      describe "@signup" do
        subject { signup }

        its(:user) { should be_new_record }
        its(:membership) { should be_nil }

        it "doesn't mark the invitation as used" do
          expect(subject.invitation).to_not be_used
        end
      end
    end
  end

  # Existing user signed in
  describe "POST #accept" do
    context "user signed in" do
      let(:user) { Fabricate(:user) }
      before do
        sign_in user
        post :accept, signup: Fabricate.attributes_for(:invitation_signup_with_existing_user, user: user)
      end
      let(:signup) { assigns(:signup) }

      it { should redirect_to(projects_path) }
      it { should assign_to(:signup) }
      it { should set_the_flash.to('You accepted the invitation successfully.') }

      it "accepts the invitation for the signed in user" do
        expect(signup.user).to eq(subject.current_user)
      end

      describe "@signup" do
        subject { signup }

        its(:membership) { should be_persisted }

        it "marks invitation as used" do
          expect(subject.invitation).to be_used
        end
      end
    end

    context "user not signed in" do
      before { post :accept, signup: Fabricate.attributes_for(:invitation_signup_with_existing_user) }

      it { should redirect_to(new_invitation_signup_path) }
      it { should set_the_flash.to('You need to be signed in to accept an invitation.') }
    end
  end
end
