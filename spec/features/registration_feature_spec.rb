require 'spec_helper'

describe 'Registration' do
  include_context 'signup feature'

  before do
    # Create invitation
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

    @invitation = Invitation.first.decorate
  end

  it "registers a new user given a valid invitation" do
    visit @invitation.registration_url

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

    # Permission for project has been created
    within('.navbar .project-links') do
      expect(page).to have_content("Rainmakers")
    end
  end
end
