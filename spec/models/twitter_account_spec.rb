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
end
