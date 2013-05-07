require 'spec_helper'

describe 'Login' do
  describe 'user logs in and out' do
    before do
      Fabricate(:user,
        name: 'Thomas Klemm',
        email: 'thomas@tklemm.eu',
        password: '123123123',
        password_confirmation: '123123123'
      )
    end

    it 'user logs in and out' do
      visit root_path
      click_on 'Login'
      expect(current_path).to eq(login_path)

      fill_in 'Email', with: 'thomas@tklemm.eu'
      fill_in 'Password', with: '123123123'
      click_button 'Login'

      expect(current_path).to eq(projects_path)
      expect(page).to have_content('Signed in successfully.')
      expect(page).to have_content('Thomas Klemm')

      click_on 'Logout'
      expect(current_path).to eq(root_path)
      expect(page).to have_content('Signed out successfully.')
    end
  end
end
