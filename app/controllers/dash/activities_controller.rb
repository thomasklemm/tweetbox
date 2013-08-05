class Dash::ActivitiesController < Dash::ApplicationController
  def index
    @activities = Activity.order(created_at: :desc).limit(1000).decorate
  end
end
