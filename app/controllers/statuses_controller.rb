class StatusesController < ProjectController
  def new
    @status = Status.new(reply_params)
    reply_to_tweet.try(:create_event, :start_reply, current_user)
  end

  def create
    @status = Status.new(status_params)

    if @status.save
      redirect_to project_tweet_path(@project, redirect_target_tweet), notice: "#{ @status.reply? ? 'Reply' : 'Status' } has been posted."
    else
      render :new
    end
  end

  private

  def reply_params
    { project: @project,
      user: current_user,
      reply_to_tweet: reply_to_tweet }
  end

  def reply_to_tweet
    params[:tweet_id] && (@reply_to_tweet ||= @project.find_or_fetch_tweet(params[:tweet_id]))
  end

  def status_params
    params[:status]
      .slice(:text, :twitter_account_id)
      .merge({
        project: @project,
        user: current_user,
        reply_to_tweet: reply_to_tweet
      })
  end

  def redirect_target_tweet
    @status.reply_to_tweet || @status.posted_tweet
  end
end
