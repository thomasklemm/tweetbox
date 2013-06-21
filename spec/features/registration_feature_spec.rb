require 'spec_helper'

describe 'Registration' do
  before do
    # Open signup page
    visit new_signup_path
    expect(current_path).to eq(new_signup_path)

    # Fill in valid details and submit signup form
    fill_in 'Your name',  with: 'Thomas Klemm'
    fill_in 'Company',    with: 'Rainmakers'
    fill_in 'Your email', with: 'thomas@rainmakers.com'
    fill_in 'password',   with: 'rainmaking123'
    click_button 'Sign up'

    # Instant sign in
    expect(current_path).to match(project_tweets_path(Project.first))

    # Create invitation
    click_on 'Account'
    click_on 'Invitations'
    expect(current_path).to eq(account_invitations_path)

    click_on 'Invite a colleague'
    expect(current_path).to eq(new_account_invitation_path)

    fill_in 'Name', with: 'Philipp Thiel'
    fill_in 'Email', with: 'philipp@rainmakers.com'
    click_on 'Create Invitation'

    expect(page).to have_content("Invitation has been created and mailed")

    @invitation = Invitation.first.decorate
  end

  it "registers a new user given a valid invitation" do
    visit @invitation.registration_url
    expect(page).to have_content("Please logout and return to complete a new registration")

    click_on 'Logout'
    expect(page).to have_content("Signed out successfully")

    visit @invitation.registration_url
    within('form#new_registration') do
      # Prefilled inputs
      expect(find('#registration_name').value).to eq('Philipp Thiel')
      expect(find('#registration_email').value).to eq('philipp@rainmakers.com')
      fill_in 'password', with: 'rainmaking123'
    end

    click_on 'Register'

    expect(current_path).to eq(project_tweets_path(Project.first))

    # Permission for project has been created
    within('.navbar .project-links') do
      expect(page).to have_content("Rainmakers")
    end
  end
end
