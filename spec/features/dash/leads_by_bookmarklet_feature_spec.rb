require 'spec_helper'

describe 'Add a lead by Bookmarklet' do
  include_context 'staff member signs in'

  it "fetches the lead from Twitter" do
    # First visit triggers fetch from Twitter
    VCR.use_cassette('dash/users/simyo') do
      visit '/dash/leads/simyo'
    end

    expect(current_path).to eq('/dash/leads/simyo')
    expect(page).to have_content("@simyo")
    expect(page).to have_content("simyo Deutschland")

    # No HTTP request on second visit
    visit '/dash/leads/simyo'
    expect(current_path).to eq('/dash/leads/simyo')

    # Click on update retrieves the latest tweets
    VCR.use_cassette('dash/user_timelines/simyo') do
      click_on 'Refresh'
    end

    expect(page).to have_content("@simyo has been updated from Twitter.")
    expect(page).to have_content("from 5 tweets")
  end
end
