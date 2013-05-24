class RetweetsController < TweetController
  def new
    @retweet = Retweet.new
  end

  def create
    @retweet = Retweet.new(retweet_params)

    if @retweet.save
      redirect_to project_tweet_path(@project, @retweet.new_tweet), notice: "Retweet has been posted."
    else
      render :new
    end
  end

  private

  def retweet_params
    params[:retweet].slice(:twitter_account_id).merge(project: @project, tweet: @tweet, user: current_user)
  end
end
