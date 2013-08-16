class TweetPusher
  include ActionView::Helpers

  attr_reader :tweet

  def initialize(tweet)
    @tweet = tweet
  end

  def replace_tweet
    data = {
      tag: "." + dom_id(tweet),
      tweet: app_controller.render_to_string(partial: 'tweets/tweet', locals: {tweet: tweet})
    }

    Pusher.trigger(channel, 'replace-tweet', data)
  end

  private

def action_view
  controller = ActionController::Base.new
  controller.request = ActionDispatch::TestRequest.new
  TaskActionView.new(Rails.root.join('app', 'views'), {}, controller)
end

  def renderer
    # ActionView::Base.new(Rails.root.join('app', 'views'))
    ac = ActionController::Base.new
    ac
  end

  # def view
  #   controller = ActionController::Base.new
  #   view = ActionView::Base.new('app/views', {}, controller)
  # end

def view(url_options = {}, *view_args)
  view_args[0] ||= ActionController::Base.view_paths
  view_args[1] ||= {}

  view = ActionView::Base.new(*view_args)
  routes = Rails.application.routes
  routes.default_url_options = {:host => 'localhost'}.merge(url_options)

  view.class_eval do
    include ApplicationHelper
    include routes.url_helpers
  end

  assigns = instance_variables.inject(Hash.new) do |hash, name|
    hash.merge name[1..-1] => instance_variable_get(name)
  end
  view.assign assigns

  view
end

def view2
  app = Tweetbox::Application
  app.routes.default_url_options = { :host => 'tweetbox.dev' }
  controller = ApplicationController.new
  view = ActionView::Base.new(Rails.root.join('app', 'views'), {}, controller)
  view.class_eval do
    include ApplicationHelper
    include app.routes.url_helpers
  end
  view
end

def helpers
ApplicationController.helpers
end

def app_controller
  ApplicationController.new
end

end

class TaskActionView < ActionView::Base
  include Rails.application.routes.url_helpers
  include ApplicationHelper

  def default_url_options
     {host: 'tweetbox.dev'}
  end
end

# ApplicationController.new.render_to_string(partial: 'tweets/tweet', locals: {tweet: Tweet.first})
# =>
#   Tweet Load (0.8ms)  SELECT "tweets".* FROM "tweets" ORDER BY "tweets"."id" ASC LIMIT 1
#   Author Load (0.6ms)  SELECT "authors".* FROM "authors" WHERE "authors"."id" = $1 ORDER BY "authors"."id" ASC LIMIT 1  [["id", 1]]
#   Status Load (0.6ms)  SELECT "statuses".* FROM "statuses" WHERE "statuses"."twitter_id" = 367523226848866304 LIMIT 1
#   Rendered tweets/_tweet_body.html.slim (17.5ms)
#   Rendered tweets/_resolved_tweet.html.slim (23.7ms)
#   Rendered tweets/_tweet.html.slim (28.1ms)
# ActionView::Template::Error: undefined method `tweet_path' for #<#<Class:0x007fb21bf797a0>:0x007fb21cb009e8>
# from /Users/thomasklemm/.rbenv/versions/2.0.0-p195/lib/ruby/gems/2.0.0/gems/actionpack-4.0.0/lib/action_dispatch/routing/polymorphic_routes.rb:129:in `polymorphic_url'


# ActionController::Base.new.render_to_string
# ActionView::Base.new(Rails.root.join('app', 'views')).render()
