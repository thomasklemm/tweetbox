class StatusesController < ProjectController
  before_action :load_status, only: [:show]

  # Pass in_reply_to: twitter_id
  def new
    @status = project_statuses.build(reply_params)
  end

  def create
    @status = project_statuses.build(status_params)

    respond_to do |format|
      if @status.save
        @status.publish!
        track 'Status Publish', @status

        format.js
        format.html { redirect_to [@project, @status],
          notice: "#{ @status.reply? ? 'Reply' : 'Tweet' } has been posted to Twitter." }
      else
        render :new
      end
    end
  end

  def show
    redirect_to [@project, @status.tweet]
  end

  private

  def project_statuses
    @project.statuses
  end

  def project_status
    project_statuses.find_by!(token: params[:id])
  end

  def load_status
    @status ||= project_status
  end

  def reply_params
    params[:in_reply_to] ? { in_reply_to_status_id: params[:in_reply_to] } : nil
  end

  def status_params
    params.
      require(:status).
      permit(:text, :twitter_account_id, :in_reply_to_status_id).
      merge(user: current_user)
  end
end
