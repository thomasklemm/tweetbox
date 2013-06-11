require 'spec_helper'

describe 'Signup and login' do
  it 'creates user, account, membership and permission records' do
    # Open signup page
    visit new_signup_path
    expect(current_path).to eq(new_signup_path)

    # Submit invalid details
    click_button 'Sign up'

    # Validation errors
    expect(page).to have_content("Name can't be blank")
    expect(page).to have_content("Company name can't be blank")
    expect(page).to have_content("Email can't be blank")
    expect(page).to have_content("Password can't be blank")

    # Fill in valid details and submit signup form
    fill_in 'Your name',  with: 'Thomas Klemm'
    fill_in 'Company',    with: '37signals'
    fill_in 'Your email', with: 'thomas@example.com'
    fill_in 'password',   with: '123123123'
    click_button 'Sign up'

    # Instant sign in
    expect(current_path).to match(incoming_project_tweets_path(Project.first))

    # Logout
    click_on 'Logout'
    expect(current_path).to eq(root_path)
    expect(page).to have_content('Signed out successfully.')

    # Login
    click_on 'Login'
    expect(current_path).to eq(login_path)

    fill_in 'Email', with: 'thomas@example.com'
    fill_in 'Password', with: '123123123'
    click_button 'Login'

    # expect(page).to have_content('Signed in successfully.')
    expect(current_path).to match(incoming_project_tweets_path(Project.first))

    # Account
    click_on 'Account'
    expect(current_path).to eq(account_projects_path)
    expect(page).to have_content('37signals')
  end
end
