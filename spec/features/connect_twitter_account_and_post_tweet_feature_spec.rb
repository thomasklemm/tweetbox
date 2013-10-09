require 'spec_helper'

describe 'Connect a Twitter account and post tweet' do
  include_context 'signup feature'

  it "connects a Twitter account" do
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

    # Publish a tweet
    click_on 'New Tweet'
    text = "Aenean eu leo quam. Pellentesque ornare sem lacinia
        quam venenatis vestibulum. Nulla vitae elit libero, a pharetra augue. Cum sociis natoque
        penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam porta sem malesuada
        magna mollis euismod. Aenean lacinia bibendum nulla sed consectetur. Sed posuere consectetur
        est at lobortis."

    VCR.use_cassette('features/connect_twitter_account/post_long_tweet') do
      within '#new_status' do
        fill_in 'status_text', with: text
        fill_in 'status_twitter_account_id', with: TwitterAccount.first.id
        click_on 'Post Tweet'
      end
    end

    status = Status.first

    expect(page).to have_content("Tweet has been posted to Twitter.")
    expect(page).to have_content(status.text)

    # Public view
    path = public_status_path(status.token)
    visit path
    expect(current_path).to eq(path)

    expect(page).to have_content(status.text)
  end
end
