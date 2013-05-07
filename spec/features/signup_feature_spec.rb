require 'spec_helper'

describe Signup do
  before { Fabricate(:trial_plan) }

  it 'creates the user' do
    visit root_path
    click_on 'Signup'
    expect(current_path).to eq(new_signup_path)

    fill_in 'Your name', with: 'Thomas Klemm'
    fill_in 'Company', with: 'Awesome Co.'
    fill_in 'Your email', with: 'awesome@tklemm.eu'
    fill_in 'password', with: 'awesome123'

    click_on 'Signup'
    expect(current_path).to eq(projects_path)
    expect(page).to have_content('Awesome Co.')

    click_on 'Logout'
    expect(current_path).to eq(root_path)

    click_on 'Login'
    expect(current_path).to eq(login_path)

    fill_in 'Email', with: 'awesome@tklemm.eu'
    fill_in 'Password', with: 'awesome123'

    click_button 'Login'
    expect(current_path).to match(/projects\/\d+/)

    click_on 'My accounts'
    expect(current_path).to eq(accounts_path)
    expect(page).to have_content('Awesome Co.')
  end
end
