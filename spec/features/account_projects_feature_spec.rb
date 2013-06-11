require 'spec_helper'

describe 'Account projects' do
  let!(:signup) { Fabricate(:persisted_signup) }

  before do
    # Persist
    signup.save

    # Login
    visit login_path
    fill_in 'Email', with: signup.email
    fill_in 'Password', with: signup.password
    click_button 'Login'

    expect(current_path).to eq(incoming_project_tweets_path(Project.first))
  end

  it 'lists all projects' do
    # Account
    click_on 'Account'

    # Account projects
    expect(current_path).to eq(account_projects_path)
  end
end
