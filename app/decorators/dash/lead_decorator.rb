class LeadDecorator < Draper::Decorator
  delegate_all
  # decorates_association :tweets

  def at_screen_name
    "@#{ screen_name }"
  end

  def description
    h.link_twitter_text(model.description)
  end

  def url
    h.link_twitter_text(model.url)
  end

  def twitter_url
    "https://twitter.com/#{ screen_name }"
  end

  def lead_path
    h.dash_lead_path(self)
  end

  def joined_twitter_on
    joined_twitter_at.to_date.to_s(:long)
  end

  def statuses_count
    h.number_with_delimiter(model.statuses_count)
  end

  def followers_count
    h.number_with_delimiter(model.followers_count)
  end

  def friends_count
    h.number_with_delimiter(model.friends_count)
  end

  def response_rate
    @response_rate ||= begin
      replies = ordered_tweets.map(&:in_reply_to_status_id).compact.length
      h.number_to_percentage(replies*100 / tweets.size, precision: 0)
    end
  end

  def sources
    @sources ||= begin
      sources = ordered_tweets.map(&:source)
      sources &&= sources.each_with_object({}) { |source, h| h[source] ||= 0; h[source] +=1 }
      sources &&= sources.sort_by { |k, v| v}.reverse.map(&:first)
      sources &&= sources.to_sentence.html_safe
    end
  end

  alias_method :source, :sources

  def grouped_sources
    @grouped_sources ||= model.tweets.group('source').count.sort_by(&:last).reverse
  end

  def grouped_sources_for_chart
    grouped_sources.map { |k,v| [h.strip_links(k.dup), v] }
  end

  def weighted_sources
    @weighted_sources ||= begin
      sources = grouped_sources
      sources &&= sources.map{ |source, count| [ source, h.number_to_percentage((count * 100 / sources.map(&:last).sum.to_f), precision: 0) ] }
      sources &&= sources.map{ |source, percentage| "#{ source } (#{ percentage })" }
      sources.to_sentence(words_connector: ',<br>', two_words_connector: ',<br>', last_word_connector: ',<br>').html_safe
    end
  end
end
