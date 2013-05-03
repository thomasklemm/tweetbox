require 'spec_helper'

# TODO: Extract
include Warden::Test::Helpers
Warden.test_mode!

def sign_in(user)
  login_as(user, scope: :user)
end

def sign_out
  logout(:user)
end

shared_context 'account features' do
  let(:user) { Fabricate(:user) }

  before do
    Fabricate(:trial_plan)
    sign_in user
  end
end

describe Account, 'list accounts' do
  include_context 'account features'
end

describe Account, 'create account' do
  include_context 'account features'

  it 'creates the account' do
    visit accounts_path
    expect(current_path).to eq(accounts_path)

    click_on 'new account'
    expect(current_path).to eq(new_account_path)
    fill_in 'Name', with: 'Awesome Co.'
    click_button 'Create'

    expect(current_path).to match(/accounts\/\d+/)
    expect(page).to have_content(/Account has been created/)
    expect(page).to have_content('Awesome Co.')
  end
end
