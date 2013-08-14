class StatusesController < ProjectController
  before_action :load_status, only: [:preview, :edit, :update, :publish, :published]

  # Pass in_reply_to: twitter_id
  def new
    @status = project_statuses.build(reply_params)
  end

  def create
    @status = project_statuses.build(status_params)

    if @status.save
      redirect_to [:preview, @project, @status]
    else
      render :new
    end
  end

  # GET statuses/:id/preview
  def preview
  end

  def edit
    render :new
  end

  def update
    if @status.update(status_params)
      redirect_to [:preview, @project, @status]
    else
      render :new
    end
  end

  # POST statuses/:id/publish
  def publish
    @status.publish! # will only publish status once

    if @status.previous_tweet
      # Resolve the previous tweet
      if params[:resolve].to_s == 'resolve'
        @status.previous_tweet.resolve_by(current_user)
        redirect_to incoming_project_tweets_path(@project),
          notice: "Reply has been posted and Tweet has been resolved. You responded in #{ @status.decorate.response_time_in_words }."
      else
        redirect_to [@project, @status.previous_tweet],
          notice: "Reply has been published."
      end
    else
      redirect_to [:published, @project, @status],
        notice: "Status has been published."
    end
  end

  # GET statuses/:id/published
  def published
    redirect_to [:preview, @project, @status] unless @status.published?
    render 'public_statuses/show'
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
