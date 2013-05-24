class StatusesController < ProjectController
  def new
    @in_reply_to_user = params.delete(:in_reply_to_user)
    @status = @project.statuses.build(initial_reply_params)
  end

  def create
    @status = @project.statuses.build(status_params)

    if @status.save
      tweet = @status.post!
      redirect_to project_tweet_path(@project, @status.in_reply_to_tweet || tweet), notice: 'Status has been created and posted.'
    else
      render :new
    end
  end

  private

  def initial_reply_params
    params.permit(:project_id, :in_reply_to_status_id)
  end

  def status_params
    params.require(:status).permit(:text, :twitter_account_id, :in_reply_to_status_id).merge(user: current_user)
  end
end
