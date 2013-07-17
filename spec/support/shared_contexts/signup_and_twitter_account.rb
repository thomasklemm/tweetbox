shared_context "signup and twitter account" do
  include_context "signup"

  let(:auth_hash) { YAML.load(File.read(Rails.root.join("spec", "support", "omniauth", "twitter.yml"))) }
  let(:twitter_account) { TwitterAccount.from_omniauth(project, auth_hash, 'write') }

  private

  # Returns a tweet record
  def fetch_and_make_tweet(twitter_id)
    make_tweet(fetch_status(twitter_id))
  end

  def fetch_status(twitter_id)
    statuses_cassette(twitter_id) { twitter_account.client.status(twitter_id) }
  end

  def statuses_cassette(twitter_id)
    VCR.use_cassette("statuses/#{ twitter_id }") { yield }
  end

  def make_tweet(status)
    TweetMaker.from_twitter(status, project: project, twitter_account: twitter_account, state: :incoming)
  end
end
