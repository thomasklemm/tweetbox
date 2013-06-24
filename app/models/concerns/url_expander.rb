module URLExpander
  # Takes a text that includes shortened t.co urls and returns it containing the expanded ones
  def expand_urls(text, urls)
    Twitter::Rewriter.rewrite_entities(text, urls) { |url| url.expanded_url }
  end
end
