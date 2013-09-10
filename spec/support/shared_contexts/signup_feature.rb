shared_context "signup feature" do
  before do
    # Open signup page
    visit new_signup_path
    expect(current_path).to eq(new_signup_path)

    # Fill in valid details and submit signup form
    fill_in 'signup_first_name',   with: 'Thomas'
    fill_in 'signup_last_name',    with: 'Klemm'
    fill_in 'signup_company_name', with: 'Rainmakers'
    fill_in 'signup_email',        with: 'thomas@rainmakers.com'
    fill_in 'signup_password',     with: 'rainmaking123'

    click_button 'Sign up free'

    # Instant sign in
    expect(current_path).to match(project_path(Project.first))
  end
end
