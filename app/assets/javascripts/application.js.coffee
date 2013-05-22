# application.js.coffee
# load jQuery beforhand
//= require jquery_ujs
//= require bootstrap
//= require jquery.autosize
//= require select2
//= require ZeroClipboard
//= require jquery.bootstrap-growl
//= require twitter-text

# Preview new status
@StatusController = ($scope) ->
  $scope.statusCharCount = ->
    twttr.txt.getTweetLength(@statusText)

  $scope.previewCharCount = ->
    twttr.txt.getTweetLength(@previewText)

  $scope.virtualCharCount = ->
    twttr.txt.getTweetLength(@virtualText)

  $scope.updatePreview = ->
    @virtualText = @statusText

    if @virtualCharCount() <= 140
      @previewText = @virtualText
    else
      while @virtualCharCount() > 114
        @virtualText = @virtualText.substr(0, @virtualText.length - 1)

      @previewText = @virtualText + "...\nhttp://tweetbox.com/read-more"

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
