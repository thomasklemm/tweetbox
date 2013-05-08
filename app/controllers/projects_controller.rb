class ProjectsController < ApplicationController
  before_filter :authenticate_user!
  after_filter  :verify_authorized, except: :index

  # Use the project layout only for the show action
  layout 'project', only: :show

  # resources :accounts do
  #   resources :projects, except: [:index, :show]
  # end
  def new
    @project = user_account_projects.build
    authorize @project
  end

  def create
    @project = user_account_projects.build(project_params)
    authorize @project
    if @project.save
      redirect_to project_path(@project),
        notice: 'Project was successfully created.'
    else
      render action: :new
    end
  end

  def edit
    @project = user_account_projects.find(params[:id])
    authorize @project
  end

  def update
    @project = user_account_projects.find(params[:id])
    authorize @project
    if @project.update_attributes(project_params)
      redirect_to project_path(@project),
        notice: 'Project was successfully updated.'
    else
      render action: :edit
    end
  end

  def destroy
    @project = user_account_projects.find(params[:id])
    authorize @project

    account = @project.account
    @project.destroy
    redirect_to account_path(account), notice: 'Project was successfully destroyed.'
  end

  # resources :projects, only: [:index, :show]
  def index
    @projects = user_projects
  end

  def show
    @project = user_project
    authorize @project, :show?
    redirect_to project_tweets_path(@project, flow: :incoming)
  end

  private

  def user_account_projects
    user_account.projects
  end

  def project_params
    params.require(:project).permit(:name)
  end
end
