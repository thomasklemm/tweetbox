# == Schema Information
#
# Table name: twitter_accounts
#
#  auth_scope            :string(255)
#  created_at            :datetime         not null
#  description           :string(255)
#  get_home              :boolean          default(TRUE)
#  get_mentions          :boolean          default(TRUE)
#  id                    :integer          not null, primary key
#  location              :string(255)
#  max_home_tweet_id     :integer
#  max_mentions_tweet_id :integer
#  name                  :string(255)
#  profile_image_url     :string(255)
#  project_id            :integer
#  screen_name           :string(255)
#  token                 :string(255)
#  token_secret          :string(255)
#  twitter_id            :integer
#  uid                   :string(255)
#  updated_at            :datetime         not null
#  url                   :string(255)
#
# Indexes
#
#  index_twitter_accounts_on_project_id          (project_id)
#  index_twitter_accounts_on_project_id_and_uid  (project_id,uid) UNIQUE
#  index_twitter_accounts_on_twitter_id          (twitter_id) UNIQUE
#

require 'spec_helper'

describe TwitterAccount do
  subject(:twitter_account) { Fabricate.build(:twitter_account) }
  it { should be_valid }

  it { should belong_to(:project) }
  it { should validate_presence_of(:project) }

  it { should have_many(:searches).dependent(:destroy) }

  it { should validate_presence_of(:twitter_id) }
  it { should validate_uniqueness_of(:twitter_id) }

  it { should validate_presence_of(:uid) }
  it { should validate_presence_of(:token) }
  it { should validate_presence_of(:token_secret) }

  it { should ensure_inclusion_of(:auth_scope).in_array(%w(read write messages)) }

  describe "#twitter_client" do
    let(:twitter_account) { Fabricate.build(:twitter_account, token: 'my_token', token_secret: 'my_token_secret') }
    let(:client) { twitter_account.twitter_client }

    it "returns a Twitter::Client instance" do
      expect(client).to be_a(Twitter::Client)
    end

    it "sets the twitter account's credentials" do
      expect(client.instance_values['oauth_token']).to eq('my_token')
      expect(client.instance_values['oauth_token_secret']).to eq('my_token_secret')
    end

    it "sets the consumer credentials" do
      expect(client.instance_values['consumer_key']).to eq('my_consumer_key')
      expect(client.instance_values['consumer_secret']).to eq('my_consumer_secret')
    end
  end

  it { should respond_to(:client) }

  pending ".from_omniauth"
end
