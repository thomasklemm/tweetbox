class ProjectsController < ProjectController
  skip_before_filter :load_and_authorize_project, only: :index
  skip_after_filter :verify_authorized, only: :index

  layout 'projects', only: :index

  def index
    @projects = user_projects
  end

  def show
    redirect_to project_tweets_path(@project)
  end
end
