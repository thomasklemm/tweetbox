# SimpleTweetPipeline
#
# Autolinks the tweet text of tweets retrieved from Twitter
#
class SimpleTweetPipeline
  include AutoHtml
  include Twitter::Autolink

  def initialize(text)
    @text = text
  end
  attr_reader :text

  def to_html
    # Sanitize text and autolink
    result = pipeline.call(text)
    html = result[:output].to_s

    # Link Twitter usernames
    html = auto_link_usernames_or_lists(html, auto_link_usernames_opts)

    # Embed videos and images and autolink urls
    auto_html(html) { link(target: '_blank') }
  end

  private

  def pipeline
    @pipeline ||= HTML::Pipeline.new [
      HTML::Pipeline::PlainTextInputFilter,
      HTML::Pipeline::SanitizationFilter
    ]
  end

  def auto_link_usernames_opts
    { username_url_base: "https://twitter.com/intent/user?screen_name=",
      username_include_symbol: true,
      username_class: "user-mention" }
  end
end
