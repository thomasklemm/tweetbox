require 'spec_helper'

describe 'Connect a Twitter account' do
  before do
    # Open signup page
    visit new_signup_path
    expect(current_path).to eq(new_signup_path)

    # Fill in valid details and submit signup form
    fill_in 'Your name',  with: 'Thomas Klemm'
    fill_in 'Company',    with: 'Rainmakers'
    fill_in 'Your email', with: 'thomas@rainmakers.com'
    fill_in 'password',   with: 'rainmaking123'
    click_button 'Sign up'

    # Instant sign in
    expect(current_path).to match(project_tweets_path(Project.first))
  end

  it "connects a Twitter account" do
    click_on "Twitter accounts"
    click_on "Connect a Twitter account"

    VCR.use_cassette('twitter_accounts/connect') do
      click_on "Connect a Twitter account"
    end

    expect(current_path).to eq(project_twitter_accounts_path(Project.first))
    expect(page).to have_content("Twitter account @tweetbox101 has been successfully authorized.")

    raise TwitterAccount.first.to_yaml

    # Post a status
    click_on 'Post a Tweet'
    full_text = "Aenean eu leo quam. Pellentesque ornare sem lacinia
        quam venenatis vestibulum. Nulla vitae elit libero, a pharetra augue. Cum sociis natoque
        penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam porta sem malesuada
        magna mollis euismod. Aenean lacinia bibendum nulla sed consectetur. Sed posuere consectetur
        est at lobortis."

    VCR.use_cassette('post_long_tweet') do
      within '#new_status' do
        fill_in 'status_full_text', with: full_text
        fill_in 'status_twitter_account_id', with: TwitterAccount.first.id
        click_on 'Post'
      end
    end

    expect(page).to have_content("Status has been posted.")
    expect(current_path).to eq(project_tweet_path(Project.first, Tweet.posted.first))
    expect(page).to have_content(full_text)
    expect(page).to have_content("Thomas Klemm posted this tweet.")

    code = Code.first
    tweet = code.tweet

    expect(tweet.text).to eq("Aenean eu leo quam. Pellentesque ornare sem lacinia\n        quam venenatis vestibulum. Nulla vitae elit libero, a ... http://lvh.me:7000/t/1")
    expect(tweet.full_text).to eq full_text

    # NOTE: New code generated each time, even when Twitter response in static in VCR
    visit public_code_path(code)
    expect(current_path).to eq public_tweet_path('tweetbox101', tweet)

    # Get mentions timeline
    # VCR.use_cassette('mentions_timeline') do
    #   TwitterWorker.new.perform(:mentions_timeline, TwitterAccount.first)
    # end

    # click_on 'Incoming'

    # within("#tweet_#{ Tweet.incoming.first.id }") do
    #   within('.actions') do
    #     click_on 'Reply'
    #   end

    #   expect(page).to have_content("123123")
    #   click_on 'Post'
    # end


    # save_and_open_page
  end
end
