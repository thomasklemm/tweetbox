class ProjectsController < ApplicationController
  before_filter :authenticate_user!
  after_filter  :verify_authorized, except: :index

  # Use the project layout only for the show action
  # and the projects layout for the index action
  layout 'projects', only: :index
  layout 'project', only: :show

  # resources :projects, only: [:index, :show]
  def index
    @projects = user_projects
  end

  def show
    @project = user_project
    authorize @project, :access?
    redirect_to incoming_project_tweets_path(@project)
  end
end
