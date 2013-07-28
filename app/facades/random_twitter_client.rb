class RandomTwitterClient
  attr_reader :twitter_client, :twitter_account

  def initialize
    @twitter_account = TwitterAccount.random
    @twitter_client = @twitter_account.client
  end

  # Whitelist read-only Twitter API actions
  # to be performed with the random Twitter account
  delegate :user,
           :user_search,
           to: :twitter_client
end
