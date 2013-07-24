shared_context "signup feature" do
  before do
    # Open signup page
    visit new_signup_path
    expect(current_path).to eq(new_signup_path)

    # Fill in valid details and submit signup form
    fill_in 'Your name',  with: 'Thomas Klemm'
    fill_in 'Company',    with: 'Rainmakers'
    fill_in 'Your email', with: 'thomas@rainmakers.com'
    fill_in 'password',   with: 'rainmaking123'
    click_button 'Start'

    # Instant sign in
    expect(current_path).to match(projects_path)
  end
end
