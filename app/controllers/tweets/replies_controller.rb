class Tweets::RepliesController < ProjectController
  before_filter :load_project_tweet

  def new
    @reply = @tweet.replies.build
    # NOTE: renders html or js
  end

  def create
    @reply = @tweet.replies.build(reply_params)

    if @reply.save
      @reply.post!

      redirect_to project_tweet_path(@project, @tweet), notice: 'Reply has been posted.'
    else
      render :new
    end
  end

  private

  def reply_params
    params.require(:reply).permit(:text, :twitter_account_id).merge(user: current_user)
  end
end
