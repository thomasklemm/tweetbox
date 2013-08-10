require 'spec_helper'

describe 'Connect a Twitter account and post Tweet' do
  include_context 'signup feature'

  it "connects a Twitter account", js: true do
    # Open project
    click_on "Rainmakers", match: :first

    click_on "Accounts"
    click_on "Connect a Twitter account"
    click_on "Connect a new Twitter account"

    VCR.use_cassette('twitter_accounts/connect') do
      click_on "Connect a Twitter account"
    end

    expect(current_path).to eq(project_twitter_accounts_path(Project.first))
    expect(page).to have_content("Your Twitter account @tweetbox101 has been connected.")

    # Publish a tweet
    click_on 'Tweet'
    text = "Aenean eu leo quam. Pellentesque ornare sem lacinia
        quam venenatis vestibulum. Nulla vitae elit libero, a pharetra augue. Cum sociis natoque
        penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam porta sem malesuada
        magna mollis euismod. Aenean lacinia bibendum nulla sed consectetur. Sed posuere consectetur
        est at lobortis."

    VCR.use_cassette('post_long_tweet') do
      within '#new_status' do
        fill_in 'status_text', with: text
        fill_in 'status_twitter_account_id', with: TwitterAccount.first.id
        click_on 'Preview'
      end
    end

    # expect(page).to have_content("Status has been posted.")
    # expect(current_path).to eq(project_tweet_path(Project.first, Tweet.posted.first))
    # expect(page).to have_content(full_text)
    # expect(page).to have_content("Thomas Klemm posted this tweet.")

    # code = Code.first
    # tweet = code.tweet

    # expect(tweet.text).to eq("Aenean eu leo quam. Pellentesque ornare sem lacinia\n        quam venenatis vestibulum. Nulla vitae elit libero, a ... http://lvh.me:7000/t/1")
    # expect(tweet.full_text).to eq full_text

    # # NOTE: New code generated each time, even when Twitter response in static in VCR
    # visit public_code_path(code)
    # expect(current_path).to eq public_tweet_path('tweetbox101', tweet)
  end
end
