class ProjectsController < ProjectController
  skip_before_filter :load_and_authorize_project, only: :index
  skip_after_filter :verify_authorized, only: :index

  def index
    redirect_to main_user_project_path
  end

  def show
    redirect_to incoming_project_tweets_path(@project)
  end
end
