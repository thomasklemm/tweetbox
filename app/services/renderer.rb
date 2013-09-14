# Render views and partials in rake tasks,
# background workers, service objects and more
#
# Use:
#
# class MyService
#   def render_stuff
#     result = Renderer.render(partial: 'tweets/tweet', locals: {tweet: Tweet.first})
#     # or even
#     result = Renderer.render(Tweet.first)
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
