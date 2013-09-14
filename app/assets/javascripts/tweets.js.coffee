# tweets
@Tweets =
  poll: ->
    setInterval @request, 5000

  request: ->
    url = $('#tweets').data('url')
    ids = $('#tweets .conversation_for_tweet').map ->
      $(this).data('twitter-id')
    min_id = if ids.length > 0 then Math.max.apply(null, ids) else ''
    url = url + '?min_id=' + min_id
    $.getScript(url)

  prependTweets: (tweets) ->
    if tweets.length > 0
      $tweets = $(tweets)
      $tweets.find('abbr.timeago').timeago()
      $('#tweets').prepend($tweets)

  appendTweets: (tweets) ->
    if tweets.length > 0
      $tweets = $(tweets)
      $tweets.find('abbr.timeago').timeago()
      $('#tweets').append($tweets)

  replaceTweet: (tag, tweet) ->
    $tweet = $(tweet)
    $tweet.find('abbr.timeago').timeago()
    $(tag).after($tweet).remove()
