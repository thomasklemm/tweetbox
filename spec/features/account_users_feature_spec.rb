require 'spec_helper'

describe 'Account users' do
  include_context 'signup feature'

  before do
    # Invitation
    click_on 'Account'
    click_on 'Invitation'
    click_on 'Invite a team member'
    expect(current_path).to eq(new_account_invitation_path)

    fill_in 'invitation_first_name', with: 'Philipp'
    fill_in 'invitation_last_name', with: 'Thiel'
    fill_in 'invitation_email', with: 'philipp@rainmakers.com'
    click_on 'Create and email invitation'

    expect(page).to have_content("Invitation has been created and mailed")

    invitation = Invitation.first.decorate

    click_on 'Logout'
    expect(page).to have_content("Signed out successfully")

    visit invitation.registration_url
    within('form#new_registration') do
      # Prefilled inputs
      expect(find('#registration_first_name').value).to eq('Philipp')
      expect(find('#registration_last_name').value).to eq('Thiel')
      expect(find('#registration_email').value).to eq('philipp@rainmakers.com')
      fill_in 'password', with: 'rainmaking123'
    end

    click_on 'Join my team'

    # Instant login
    expect(current_path).to eq(incoming_project_tweets_path(Project.first))

    # Login as base user
    click_on 'Logout'
    click_on 'Login'
    fill_in 'Email', with: 'thomas@rainmakers.com'
    fill_in 'Password', with: 'rainmaking123'
    click_button 'Login'
  end

  it "lists users, grants admin membership" do
    click_on 'Account'
    click_on 'Team', match: :first
    expect(current_path).to eq(account_users_path)

    within('.users-table') do
      expect(page).to have_content("Thomas Klemmthomas@rainmakers.com Is an Account Admin")
      expect(page).to have_content("Philipp Thielphilipp@rainmakers.com Grant admin superpowers")
    end

    # Grant admin membership
    click_on 'Grant admin superpowers'
    expect(page).to have_content("Philipp Thiel has become an account admin")

    within('.users-table') do
      expect(page).to have_content("Thomas Klemmthomas@rainmakers.com Is an Account Admin")
      expect(page).to have_content("Philipp Thielphilipp@rainmakers.com Is an Account Admin")
    end
  end
end
