class RepliesController < TweetController
  def new
    @tweet.start_reply_by(current_user)
    redirect_to new_project_status_path(in_reply_to: @tweet.twitter_id)
  end
end
