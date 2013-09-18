# Render views and partials in rake tasks,
# background workers, service objects and more
#
# Use:
#
# class MyService
#   def render_stuff
#     result = Renderer.new.render(partial: 'tweets/tweet', locals: {tweet: Tweet.first})
#     # or even
#     result = Renderer.new.render(Tweet.first)
#   end
# end
#
class Renderer
  def self.new
    @renderer ||= begin
      controller = ApplicationController.new
      controller.request = ActionDispatch::TestRequest.new
      ViewRenderer.new(Rails.root.join('app', 'views'), {}, controller)
    end
  end
end

class ViewRenderer < ActionView::Base
  include Rails.application.routes.url_helpers
  include ApplicationHelper

  def default_url_options
     {host: Rails.application.routes.default_url_options[:host]}
  end
end
