require 'spec_helper'

describe 'Registration' do
  describe 'user registers without invitation code' do
    it 'creates the user and logs her in' do
      visit new_registration_path
      expect(current_path).to eq(new_registration_path)

      fill_in 'Your full name', with: 'Thomas Klemm'
      fill_in 'Email', with: 'thomas@tklemm.eu'
      fill_in 'Password', with: '123123123'
      click_button 'Sign up'

      expect(current_path).to eq(projects_path)
      expect(page).to have_content('You have signed up successfully.')
      expect(page).to have_content('Thomas Klemm')

      click_on 'Logout'
      expect(current_path).to eq(root_path)
      expect(page).to have_content('Signed out successfully.')

      click_on 'Login'
      expect(current_path).to eq(login_path)

      fill_in 'Email', with: 'thomas@tklemm.eu'
      fill_in 'Password', with: '123123123'
      click_button 'Login'

      expect(current_path).to eq(projects_path)
      expect(page).to have_content('Signed in successfully.')
    end
  end

  describe 'user registers with invitation code' do
    pending
  end
end
