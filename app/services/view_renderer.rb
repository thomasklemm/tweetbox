# A helper class for Renderer
class ViewRenderer < ActionView::Base
  include Rails.application.routes.url_helpers
  include ApplicationHelper

  def default_url_options
     {host: 'tweetbox.dev'}
  end
end
