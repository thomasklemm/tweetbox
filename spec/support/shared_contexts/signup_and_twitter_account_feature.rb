shared_context "signup and twitter account feature" do
  include_context "signup feature"

  before do
    # Open project
    click_on "Rainmakers", match: :first

    click_on "Accounts"
    click_on "Connect a Twitter account"
    click_on "Connect a new Twitter account"

    VCR.use_cassette('features/connect_twitter_account/connect') do
      click_on "Connect a Twitter account"
    end

    expect(current_path).to eq(project_twitter_accounts_path(Project.first))
    expect(page).to have_content("Your Twitter account @tweetbox101 has been connected.")
  end
end
