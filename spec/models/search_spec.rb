# == Schema Information
#
# Table name: searches
#
#  active             :boolean          default(TRUE)
#  created_at         :datetime         not null
#  id                 :integer          not null, primary key
#  max_tweet_id       :integer
#  project_id         :integer
#  query              :text             not null
#  twitter_account_id :integer
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_searches_on_project_id          (project_id)
#  index_searches_on_twitter_account_id  (twitter_account_id)
#

require 'spec_helper'

describe Search do
  subject(:search) { Fabricate(:search) }
  it { should be_valid }

  it { should belong_to(:twitter_account) }
  it { should belong_to(:project) }

  it { should validate_presence_of(:twitter_account) }
  it { should validate_presence_of(:term) }

  it "requires a project" do
    search = Fabricate.build(:search, twitter_account: nil)
    expect(search).to have(1).error_on(:project)
  end

  it "assigns the project from the twitter_account" do
    expect(search.project).to eq(search.twitter_account.project)
  end
end
