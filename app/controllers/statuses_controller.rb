class StatusesController < ProjectController
  def new
    @status = Status.new(reply_params).decorate
    @event = @status.reply_to_tweet.try(:create_event, :start_reply, current_user)
  end

  def create
    @status = Status.new(status_params).decorate

    if @status.save
      redirect_to project_tweet_path(@project, @status.redirect_target_tweet), notice: "#{ @status.reply? ? 'Reply' : 'Status' } has been posted."
    else
      render :new
    end
  end

  private

  def reply_params
    { project: @project,
      user: current_user,
      in_reply_to_status_id: params[:tweet_id] }
  end

  def reply_to_tweet
    params[:tweet_id] && @project.tweets.where(twitter_id: params[:tweet_id]).first!
  end

  def status_params
    params[:status]
      .slice(:text, :twitter_account_id, :in_reply_to_status_id)
      .reverse_merge({
        project: @project,
        user: current_user
      })
  end
end
