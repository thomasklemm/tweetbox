class SimpleTweetPipeline
  include AutoHtml
  include Twitter::Autolink

  def initialize(text)
    @text = text
  end

  def to_html
    result = pipeline.call(@text)
    t = auto_link_usernames_or_lists(result[:output].to_s, auto_link_usernames_opts)
    t = auto_html(t) { link(target: '_blank') }
  end

  private

  def pipeline
    @pipeline ||= HTML::Pipeline.new [
      HTML::Pipeline::PlainTextInputFilter,
      HTML::Pipeline::SanitizationFilter
    ], pipeline_context
  end

  def pipeline_context
    {
    }
  end

  def auto_link_usernames_opts
    { username_url_base: "https://twitter.com/intent/user?screen_name=",
      username_include_symbol: true,
      username_class: "user-mention" }
  end
end
