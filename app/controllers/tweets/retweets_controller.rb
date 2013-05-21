class Tweets::RetweetsController < ProjectController
  before_filter :load_project_tweet

  def new
    @retweet = @tweet.retweets.build
    # NOTE: renders html or js
  end

  def create
    @retweet = @tweet.retweets.build(retweet_params)

    return render :new unless @retweet.valid?

    # Can raise as another retweet might have been posted already
    @retweet.post!
    flash.notice = 'Retweet has been posted.'
  rescue
    flash.notice = 'Tweet has already been retweeted, and can be retweeted only once.'
  ensure
    redirect_to project_tweet_path(@project, @tweet)
  end

  private

  def retweet_params
    params.require(:retweet).permit(:twitter_account_id).merge(user: current_user)
  end
end
