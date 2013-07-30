require 'spec_helper'

describe 'Find and remember Twitter users' do
  include_context 'signup and twitter account'

  it "finds and remembers Twitter users", js: true do
    # Create Twitter account
    twitter_account

    # User search
    VCR.use_cassette('dash/user_searches/mailchimp') do
      visit search_dash_leads_path

      # Search
      fill_in 'query', with: 'MailChimp'
      click_on 'Search'

      # Pagination
      click_on 'Next page'
      click_on 'Previous page'

      # No remembered leads yet
      expect(page).to have_no_content('.edit_lead')

      # Remember Twitter account
      within '#twitter_user_14377870' do
        click_on 'Remember @MailChimp'
      end

      # Lead replaces Twitter user
      expect(page).to have_no_selector('#twitter_user_14377870')
      expect(page).to have_selector('.edit_lead')

      within '.edit_lead' do
        # Requires reload
        # expect(page).to have_content("Client(s):LongReply, TwitSpark.com, and web")

        # TODO: Select score
      end
    end
  end
end
