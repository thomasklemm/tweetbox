class TweetPipeline
  include AutoHtml

  def initialize(text)
    @text = text
  end

  def to_html
    t = auto_html(@text) { link }
    raise t.to_yaml
    result = pipeline.call(t)
    t = result[:output].to_s
    raise t.to_yaml
  end

  private

  def pipeline
    @pipeline ||= HTML::Pipeline.new [
      # Convert Markdown to HTML
      HTML::Pipeline::MarkdownFilter,
      # Whitelist sanitize user input
      HTML::Pipeline::SanitizationFilter,
      # Replace @user mentions with links
      HTML::Pipeline::MentionFilter,
      # Autolink URLs in HTML
      # HTML::Pipeline::AutolinkFilter,
      # Replace http image urls with https versions (through proxy)
      # HTML::Pipeline::CamoFilter
    ], pipeline_context
  end

  def pipeline_context
    {
      # MarkdownFilter
      # Enable Github flavored markdown syntax
      gfm: true,

      # MentionFilter
      # :base_url - Used to construct links to user profile pages for each mention.
      base_url: 'https://twitter.com/intent/user?screen_name=',
      # :info_url - Used to link to "more info" when someone mentions @mention or @mentioned.
      # info_url: ''
    }
  end
end
