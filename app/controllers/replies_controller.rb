class RepliesController < TweetController
  def new
    @status = Status.new(old_tweet: @tweet)
  end

  def create
    @status = Status.new(status_params)
  end

  private

  def status_params
    raise params.inspect
  end
end
