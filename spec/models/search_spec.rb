# == Schema Information
#
# Table name: searches
#
#  active             :boolean          default(TRUE)
#  created_at         :datetime         not null
#  id                 :integer          not null, primary key
#  max_twitter_id     :integer
#  project_id         :integer          not null
#  query              :text             not null
#  twitter_account_id :integer          not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_searches_on_project_id                         (project_id)
#  index_searches_on_project_id_and_twitter_account_id  (project_id,twitter_account_id)
#  index_searches_on_twitter_account_id                 (twitter_account_id)
#

require 'spec_helper'

describe Search do
  subject(:search) { Fabricate(:search) }
  it { should be_valid }

  it { should belong_to(:twitter_account) }
  it { should belong_to(:project) }

  it { should validate_presence_of(:twitter_account) }
  it { should validate_presence_of(:query) }

  it "requires a project" do
    search = Fabricate.build(:search, twitter_account: nil)
    expect(search).to have(2).error_on(:project)
    expect(search.errors_on(:project).uniq).to eq(["can't be blank"])
  end

  it "assigns the project from the twitter_account" do
    expect(search.project).to eq(search.twitter_account.project)
  end

  describe "#update_max_twitter_id" do
    it "updates the max twitter id only when given a higher max_twitter_id than the current one" do
      search.max_twitter_id = nil
      search.update_max_twitter_id(2)
      expect(search.max_twitter_id).to eq(2)

      # Only upgrade
      search.update_max_twitter_id(1)
      expect(search.max_twitter_id).to eq(2)
    end
  end
end
