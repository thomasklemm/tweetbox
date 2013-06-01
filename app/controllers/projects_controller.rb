class ProjectsController < ProjectController
  skip_before_filter :load_and_authorize_project, only: :index
  skip_after_filter :verify_authorized, only: :index

  layout 'projects', only: :index

  def index
    @projects = user_projects

    # Open project if there is only one?
    @projects.size == 1 and return redirect_to @projects.first
  end

  def show
    redirect_to incoming_project_tweets_path(@project)
  end
end
