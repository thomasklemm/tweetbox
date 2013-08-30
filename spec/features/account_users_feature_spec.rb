require 'spec_helper'

describe 'Account users' do
  include_context 'signup feature'

  before do
    # Invitation
    click_on 'Account'
    click_on 'Invitation'
    click_on 'Invite a colleague'
    expect(current_path).to eq(new_account_invitation_path)

    fill_in 'Name', with: 'Philipp Thiel'
    fill_in 'Email', with: 'philipp@rainmakers.com'
    click_on 'Create Invitation'

    expect(page).to have_content("Invitation has been created and mailed")

    invitation = Invitation.first.decorate

    click_on 'Logout'
    expect(page).to have_content("Signed out successfully")

    visit invitation.registration_url
    within('form#new_registration') do
      # Prefilled inputs
      expect(find('#registration_name').value).to eq('Philipp Thiel')
      expect(find('#registration_email').value).to eq('philipp@rainmakers.com')
      fill_in 'password', with: 'rainmaking123'
    end

    click_on 'Register'
    # expect(current_path).to eq(projects_path)

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
      expect(page).to have_content("Thomas Klemmthomas@rainmakers.com Account admin")
      expect(page).to have_content("Philipp Thielphilipp@rainmakers.com")
      expect(page).to have_no_content("Philipp Thielphilipp@rainmakers.com Account admin")
    end

    # Grant admin membership
    click_on 'Grant admin superpowers'
    expect(page).to have_content("Philipp Thiel has become an account admin")

    within('.users-table') do
      expect(page).to have_content("Thomas Klemmthomas@rainmakers.com Account admin")
      expect(page).to have_content("Philipp Thielphilipp@rainmakers.com Account admin")
    end
  end
end
