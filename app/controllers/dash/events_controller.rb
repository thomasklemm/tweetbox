class Dash::EventsController < Dash::ApplicationController
  def index
    @events = Event.order(created_at: :desc).
      page(params[:page]).per(100)
  end
end
