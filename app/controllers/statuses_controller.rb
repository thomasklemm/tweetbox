class StatusesController < ProjectController
  before_action :load_status, only: [:preview, :post]

  # Pass in_reply_to: twitter_id
  def new
    @status = project_statuses.build(reply_params)
  end

  def create
    @status = project_statuses.build(status_params)

    if @status.save
      redirect_to preview_project_status_path(@project, @status)
    else
      render :new
    end
  end

  # GET statuses/:id/preview
  def preview
  end

  # POST statuses/:id/publish
  def publish
    @status.publish! # won't post twice
    redirect_to new_project_status_path(@project),
      notice: "Status has been published."
  end

  private

  def project_statuses
    project.statuses
  end

  def reply_params
    opts = {}
    opts.merge({in_reply_to_status_id: params[:in_reply_to]) if params[:in_reply_to].present?
  end

  def status_params
    params.
      require(:status).
      permit(:text, :twitter_account_id, :in_reply_to_status_id).
      merge(user: current_user)
  end

  def load_status
    @status = project_statuses.find_by!(token: params[:id])
  end
end
