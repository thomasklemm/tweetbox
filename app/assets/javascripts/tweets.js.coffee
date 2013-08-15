# tweets
@TweetPusher =
  updateTweet: (tag, tweet) ->
    # Replaces multiple tags
    $(tag).replaceWith(tweet)
    # Call on entire page to catch all new dom nodes
    $("abbr.timeago").timeago()

pusher = new Pusher('bd90c5fceef54c5f2c55')
channel = pusher.subscribe('channel')
channel.bind 'update-tweet', (data) ->
  console.log(data)
  TweetPusher.updateTweet(data.tag, data.tweet)
