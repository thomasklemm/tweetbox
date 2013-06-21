require 'spec_helper'

describe 'Account invitations' do
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
  end

  it "new and create invitation and list invitations" do
    click_on 'Account'
    click_on 'Invitations'
    expect(current_path).to eq(account_invitations_path)

    click_on 'Invite a colleague'
    expect(current_path).to eq(new_account_invitation_path)

    fill_in 'Name', with: 'Philipp Thiel'
    fill_in 'Email', with: 'philipp@rainmakers.com'
    click_on 'Create Invitation'

    expect(page).to have_content("Invitation has been created and mailed")

    # list invitations
    within('.invitations-table') do
      expect(page).to have_content("1Philipp Thielphilipp@rainmakers.com")
    end

    # edit and update invitation
    within('.invitations-table') do
      click_on 'Edit'
    end

    expect(current_path).to eq(edit_account_invitation_path(Invitation.first))

    fill_in 'Name', with: 'Peter Thiel'
    fill_in 'Email', with: 'peter@rainmakers.com'
    click_on 'Update Invitation'

    expect(page).to have_content("Invitation has been updated")

    within('.invitations-table') do
      expect(page).to have_no_content("1Philipp Thielphilipp@rainmakers.com")
      expect(page).to have_content("Peter Thielpeter@rainmakers.com")
    end

    # deactivate invitation
    within('.invitations-table') do
      click_on 'deactivate'
    end

    expect(page).to have_content("Invitation has been deactivated")

    # reactivate invitation
    within('.invitations-table') do
      click_on 'reactivate'
    end

    expect(page).to have_content("Invitation has been reactivated")

    # resend invitation email
    within('.invitations-table') do
      click_on 'Resend'
    end

    expect(page).to have_content("Invitation email has been sent")
  end
end
