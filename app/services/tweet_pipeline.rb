class TweetPipeline
  include AutoHtml
  include Twitter::Autolink

  def initialize(text)
    @text = text
  end

  def to_html
    result = pipeline.call(@text)
    t = auto_link_usernames_or_lists(result[:output].to_s, auto_link_usernames_opts)
    t = auto_html(t) { link }
    #result[:output].to_s
  end

  private

  def pipeline
    @pipeline ||= HTML::Pipeline.new [
      # Convert Markdown to HTML
      HTML::Pipeline::MarkdownFilter,
      # Whitelist sanitize user input
      HTML::Pipeline::SanitizationFilter
      # Replace @user mentions with links
      # HTML::Pipeline::MentionFilter,
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
      # base_url: 'https://twitter.com/intent/user?screen_name=',
      # :info_url - Used to link to "more info" when someone mentions @mention or @mentioned.
      # info_url: ''
    }
  end

  def auto_link_usernames_opts
    { username_url_base: "https://twitter.com/intent/user?screen_name=",
      username_include_symbol: true,
      username_class: "user-mention" }
  end
end
