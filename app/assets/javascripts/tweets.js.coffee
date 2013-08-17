# tweets


# Endless scroll
jQuery ->
  if $('.pagination').length
      $(window).scroll ->
        url = $('.pagination a[rel=next]').attr('href')
        if url && $(window).scrollTop() > $(document).height() - $(window).height() - 50
          $('.pagination').text("Fetching more conversations...")
          $.getScript(url)
      $(window).scroll()

@TweetPusher =
  # Replaces multiple tweet dom nodes with new ones
  # NOTE: Can replace conversations or tweet, right now used for tweets
  # due to payload max of 10 KB on Pusher
  replaceTweet: (tag, tweet) ->
    $(tag).replaceWith(tweet)
    @updateTimestamps()

  # Prepends the given tweets to the #tweets stream
  prependConversation: (tweet) ->
    $('#tweets').prepend(tweet)
    @updateTimestamps()

  # Updates timestamps on the entire page
  updateTimestamps: ->
    $("abbr.timeago").timeago()
