# application.js.coffee
# load jQuery beforhand
//= require jquery_ujs
//= require bootstrap
//= require jquery.autosize
//= require select2
//= require ZeroClipboard
//= require jquery.bootstrap-growl
//= require twitter-text

@ReplyController = ($scope) ->
  $scope.charCount = ->
    $scope.previewTweet.length

  $scope.updatePreviewTweet = ->
    $scope.previewTweet = $scope.replyText
    extractedUrls = twttr.txt.extractUrlsWithIndices($scope.previewTweet)

    angular.forEach extractedUrls, (extract) ->
      url = extract.url
      filler = 'www.shortened-url.com'
      $scope.previewTweet = $scope.previewTweet.replace(url, filler)

    $scope.previewTweet

  $scope.previewTweetText = ->
    if $scope.charCount() <= 140
      return $scope.previewTweet
    else
      tweet = $scope.previewTweet.substr(0, 125)
      longReplyUrl = "tweetbox.com/full-reply"
      return tweet + '... ' + longReplyUrl


# function charactersleft(tweet) {
#   var url, i, lenUrlArr;
#   var virtualTweet = tweet;
#   var filler = "01234567890123456789";
#   var extractedUrls = twttr.txt.extractUrlsWithIndices(tweet);
#   var remaining = 140;
#   lenUrlArr = extractedUrls.length;
#   if ( lenUrlArr > 0 ) {
#     for (var i = 0; i < lenUrlArr; i++) {
#       url = extractedUrls[i].url;
#       virtualTweet = virtualTweet.replace(url,filler);
#     }
#   }
#   remaining = remaining - virtualTweet.length;
#   return remaining;
# }

# Birdview
$ ->
  ##
  # Autosize
  $('textarea').autosize()

  ##
  # ZeroClipboard
  clip = new ZeroClipboard($('.copy-button'), {
    moviePath: "/ZeroClipboard.swf"
  })

  # Give some feedback about what has just been copied to the clipboard
  clip.on 'complete', (client, args) ->
    $.bootstrapGrowl('Copied to Clipboard: \n "' + args.text + '"', {
        type: 'success'
      })
