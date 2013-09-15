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
