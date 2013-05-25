class StatusesController < ProjectController
  def new
    @status = Status.new(reply_params)
  end

  def create
    @status = Status.new(status_params)
    raise @status.inspect
    if @status.save
      redirect_to project_tweet_path(@project, @status.new_tweet), notice: "Status has been posted."
    else
      render :new
    end
  end

  private

  def status_params
    params[:status].slice(:twitter_account_id, :in_reply_to_status_id, :text).reverse_merge(project: @project, user: current_user)
  end

  def reply_params
    options = { project: @project, user: current_user }
    options[:in_reply_to_status_id] = in_reply_to_status_id if in_reply_to_status_id
    options
  end

  def in_reply_to_status_id
    params[:tweet_id] || params[:in_reply_to_status_id]
  end
end
