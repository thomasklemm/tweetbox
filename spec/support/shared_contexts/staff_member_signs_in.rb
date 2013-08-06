shared_context "staff member signs in" do
  include_context "signup and twitter account"

  before do
    # User is staff member
    user.update(staff_member: true)

    # Login
    visit login_path

    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Login'

    # Create twitter account
    twitter_account
  end
end
