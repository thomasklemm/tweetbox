class RepliesController < TweetController
  def new
    redirect_to new_project_status_path(in_reply_to: @tweet.twitter_id)
  end
end
