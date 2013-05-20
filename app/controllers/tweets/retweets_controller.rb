class Tweets::RetweetsController < ProjectController
  before_filter :load_project_tweet

  def new
    @retweet = Retweet.new(tweet: @tweet)
  end

  def create
    @retweet = Retweet.new(tweet: @tweet, user: current_user, twitter_account_id: params[:retweet][:twitter_account_id])

    if @retweet.post
      redirect_to project_tweet_path(@project, @tweet), notice: 'Retweet has been posted.'
    else
      redirect_to project_tweet_path(@project, @tweet), notice: 'Retweet could not be posted.'
    end
  end
end
