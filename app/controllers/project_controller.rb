class ProjectController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_and_authorize_project
  after_filter  :verify_authorized

  layout 'project'

  private

  def load_and_authorize_project
    @project ||= user_project
    authorize @project, :show?
  end
end
