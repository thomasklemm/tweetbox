# tweets

# Endless scroll
jQuery ->
  if $('.pagination').length
      $(window).scroll ->
        url = $('.pagination a[rel=next]').attr('href')
        if url && $(window).scrollTop() > $(document).height() - $(window).height() - 50
          # $('.pagination').text("Fetching more conversations...")
          $('.pagination').html("<i class='icon-spinner icon-spin'></i> Fetching more conversations...")
          $.getScript(url)
      $(window).scroll()


@TweetPusher =
  # NOTE: Can replace conversations or tweet, right now used for tweets
  # due to payload max of 10 KB (custom 13 KB payload limit) on Pusher
  replaceTweet: (tag, tweet) ->
    $tweet = $(tweet)
    $(tag).after($tweet).remove()
    @updateTimestamps()

  prependConversation: (tags, conversation) ->
    @prependC(tag, conversation) for tag in tags

  prependC: (tag, conversation) ->
    $conversation = $(conversation)
    $(tag).prepend($conversation.hide().slideDown(200))
    @updateTimestamps()

  appendTweet: (tag, tweet) ->
    $tag = $(tag)
    $tweet = $(tweet)
    $tag.append($tweet.hide().slideDown(200))
    @updateTimestamps()

  # Updates timestamps on the entire page
  updateTimestamps: ->
    $("abbr.timeago").timeago()
