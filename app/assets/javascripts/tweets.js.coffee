# tweets
@Tweets =
  poll: ->
    setInterval @request, 12000

  request: ->
    url = $('#tweets').data('poll-url')
    flow = $('#tweets').attr('data-flow')
    min_id = $('#tweets').attr('data-max-id') || ''
    url = url + '?flow=' + flow + '&min_id=' + min_id
    $.getScript(url)

  prependTweets: (tweets) ->
    if tweets.length > 0
      $tweets = $(tweets)
      $tweets.find('abbr.timeago').timeago()
      $('#tweets').prepend($tweets.hide())

      new_tweets_count = $('.conversation_for_tweet:hidden').length
      $('#show-tweets a').text('Show ' + new_tweets_count + ' new tweets.')
      $('#show-tweets').show()

  appendTweets: (tweets) ->
    if tweets.length > 0
      $tweets = $(tweets)
      $tweets.find('abbr.timeago').timeago()
      $('#tweets').append($tweets)

  replaceTweet: (tag, tweet) ->
    $tweet = $(tweet)
    $tweet.find('abbr.timeago').timeago()
    $(tag).after($tweet).remove()

  showTweets: (e) ->
    e.preventDefault()
    $('.conversation_for_tweet').show()
    $('#show-tweets').hide()

  appendTweetEvent: (tag, event) ->
    $event = $(event)
    $tag = $(tag)
    $event.find('abbr.timeago').timeago()

    current_event = $tag.find("[data-user='" + $event.data('user') + "']")
    if current_event.length
      current_event.replaceWith($event)
    else
      $tag.append($event)


@Statistics =
  updateCounts: (projects) ->
    $.each projects, (index, project) ->
      Statistics.updateCount(project)

  updateCount: (project) ->
    $('#project_' + project.id + '_count').text(if project.count > 0 then project.count else '')
