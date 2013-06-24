# == Schema Information
#
# Table name: twitter_accounts
#
#  access_scope                            :text
#  created_at                              :datetime         not null
#  description                             :text
#  id                                      :integer          not null, primary key
#  location                                :text
#  max_direct_messages_received_twitter_id :integer
#  max_direct_messages_sent_twitter_id     :integer
#  max_mentions_timeline_twitter_id        :integer
#  max_user_timeline_twitter_id            :integer
#  name                                    :text
#  profile_image_url                       :text
#  project_id                              :integer          not null
#  screen_name                             :text
#  token                                   :text             not null
#  token_secret                            :text             not null
#  twitter_id                              :integer          not null
#  uid                                     :text             not null
#  updated_at                              :datetime         not null
#  url                                     :text
#
# Indexes
#
#  index_twitter_accounts_on_project_id                   (project_id)
#  index_twitter_accounts_on_project_id_and_access_scope  (project_id,access_scope)
#  index_twitter_accounts_on_project_id_and_twitter_id    (project_id,twitter_id)
#  index_twitter_accounts_on_twitter_id                   (twitter_id) UNIQUE
#

require 'spec_helper'

describe TwitterAccount do
  subject(:twitter_account) { Fabricate.build(:twitter_account) }
  it { should be_valid }

  it { should belong_to(:project) }
  it { should have_many(:searches).dependent(:restrict) }
  it { should have_many(:tweets).dependent(:nullify) }

  it { should validate_presence_of(:project) }
  it { should validate_presence_of(:twitter_id) }

  it { should validate_presence_of(:uid) }
  it { should validate_presence_of(:token) }
  it { should validate_presence_of(:token_secret) }

  it { should ensure_inclusion_of(:access_scope).in_array(%w(read write)) }

  describe "#at_screen_name" do
    it "returns '@screenname'" do
      twitter_account.screen_name = 'thomasjklemm'
      expect(twitter_account.at_screen_name).to eq '@thomasjklemm'
    end
  end

  describe "#client" do
    it "returns a Twitter::Client instance" do
      expect(twitter_account.client).to be_a Twitter::Client
    end

    it "instantiates the Twitter::Client with the twitter account's credentials" do
      token = twitter_account.client.instance_variable_get("@oauth_token")
      token_secret = twitter_account.client.instance_variable_get("@oauth_token_secret")

      expect(token).to be_present
      expect(token).to eq(twitter_account.token)

      expect(token_secret).to be_present
      expect(token_secret).to eq(twitter_account.token_secret)
    end
  end
end

describe TwitterAccount, 'persisted' do
  subject(:twitter_account) { Fabricate(:twitter_account) }
  it { should be_valid }

  it { should validate_uniqueness_of(:twitter_id) }

  describe "callbacks" do
    it "ensures that the first connected twitter account will be made the project's default twitter account" do
      twitter_account.send(:ensure_project_default_is_set) # after_commit callback
      expect(twitter_account).to be_project_default
    end
  end
end
