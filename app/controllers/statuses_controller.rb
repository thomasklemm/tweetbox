class StatusesController < ProjectController
  def new
    @status = @project.statuses.build
  end

  def create
    @status = @project.statuses.build(status_params)
    raise @status.inspect
  end

  private

  def status_params
    params.require(:status).permit(:text, :twitter_account_id).merge(user: current_user)
  end
end
