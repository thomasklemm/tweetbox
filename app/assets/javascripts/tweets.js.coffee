# tweets
@Tweets =
  poll: ->
    setInterval @request, 10000

  request: ->
    url = $('#tweets').data('url')
    min_id = $('#tweets').attr('data-min-id') || ''
    url = url + '?min_id=' + min_id
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

