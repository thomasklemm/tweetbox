class StatusesController < ProjectController
  def new
    @status = Status.new(reply_params).decorate
    @event = @status.create_start_reply_event
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
    options = { project: @project, user: current_user }
    options[:in_reply_to_status_id] = params[:tweet_id] if params[:tweet_id].present?
    options
  end

  def reply_to_tweet
    params[:tweet_id] && @project.tweets.where(twitter_id: params[:tweet_id]).first!
  end

  def status_params
    params[:status].
      slice(:full_text, :twitter_account_id, :in_reply_to_status_id).
      reverse_merge({
        project: @project,
        user: current_user
      })
  end
end
