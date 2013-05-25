class StatusesController < ProjectController
  def new
    @status = Status.new
  end

  def create
    @status = Status.new(status_params)

    if @status.save
      redirect_to project_tweet_path(@project, @status.new_tweet), notice: "Status has been posted."
    else
      render :new
    end
  end

  private

  def status_params
    params[:status].slice(:text, :twitter_account_id).merge(project: @project, user: current_user)
  end
end
