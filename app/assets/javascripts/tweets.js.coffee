# tweets
@Tweets =
  poll: ->
    setTimeout @request, 5000

  request: ->
    url = $('#tweets').data('url')
    min_id = $('#tweets').data('min_id')
    $.get(url, min_id: min_id)

  prependTweets: (tweets) ->
    if tweets.length > 0
      $tweets = $(tweets)
      $tweets.find('abbr.timeago').timeago()
      $('#tweets').prepend($tweets.hide())
      $('#show-tweets').show()
    @poll

  appendTweets: (tweets) ->
    if tweets.length > 0
      $tweets = $(tweets)
      $tweets.find('abbr.timeago').timeago()
      $('#tweets').append($tweets)

  replaceTweet: (tag, tweet) ->
    $tweet = $(tweet)
    $tweet.find('abbr.timeago').timeago()
    $(tag).after($tweet).remove()

  timeago: ->
    $('abbr.timeago').timeago()
