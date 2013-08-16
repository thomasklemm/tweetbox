# A helper class for Renderer
class ViewRenderer < ActionView::Base
  include Rails.application.routes.url_helpers
  include ApplicationHelper

  def default_url_options
     {host: Rails.application.routes.default_url_options[:host]}
  end
end
