class Account::ProjectsController < AccountController
  before_filter :load_and_authorize_project, only: [:edit, :update]

  def index
    @projects = account_projects
  end

  def new
    @project = account_projects.build
    authorize @project, :manage?
  end

  def create
    @project = account_projects.build(project_params)
    authorize @project, :manage?

    if @project.save
      redirect_to account_projects_path, notice: 'Project has been created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @project.update_attributes(project_params)
      redirect_to account_projects_path, notice: 'Project has been updated.'
    else
      render :edit
    end
  end

  private

  def account_projects
    user_account.projects
  end

  def account_project
    account_projects.find(params[:project_id] || params[:id])
  end

  def load_and_authorize_project
    @project = account_project
    authorize @project, :manage?
  end

  def project_params
    params.require(:project).permit(:name, { membership_ids: [] })
  end
end

