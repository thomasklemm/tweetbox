require 'spec_helper'

describe 'Account invitations' do
  include_context 'signup feature'

  it "new and create invitation and list invitations" do
    click_on 'Account'
    click_on 'Invitations'
    expect(current_path).to eq(account_invitations_path)

    click_on 'Invite a team member'
    expect(current_path).to eq(new_account_invitation_path)

    fill_in 'invitation_first_name', with: 'Philipp'
    fill_in 'invitation_last_name', with: 'Thiel'
    fill_in 'invitation_email', with: 'philipp@rainmakers.com'
    click_on 'Create and email invitation'

    expect(page).to have_content("Invitation has been created and mailed")

    # list invitations
    within('.invitations-table') do
      expect(page).to have_content("Philipp Thielphilipp@rainmakers.com")
    end

    # edit and update invitation
    within('.invitations-table') do
      click_on 'Edit'
    end

    expect(current_path).to eq(edit_account_invitation_path(Invitation.first))

    fill_in 'invitation_first_name', with: 'Peter'
    fill_in 'invitation_last_name', with: 'Thiel'
    fill_in 'invitation_email', with: 'peter@rainmakers.com'
    click_on 'Update'

    expect(page).to have_content("Invitation has been updated")

    within('.invitations-table') do
      expect(page).to have_no_content("Philipp Thielphilipp@rainmakers.com")
      expect(page).to have_content("Peter Thielpeter@rainmakers.com")
    end

    # deactivate invitation
    within('.invitations-table') do
      click_on 'Deactivate'
    end

    expect(page).to have_content("Invitation has been deactivated")

    # reactivate invitation
    within('.invitations-table') do
      click_on 'Reactivate'
    end

    expect(page).to have_content("Invitation has been reactivated")

    # resend invitation email
    within('.invitations-table') do
      click_on 'Send email'
    end

    expect(page).to have_content("Invitation email has been sent")
  end
end
