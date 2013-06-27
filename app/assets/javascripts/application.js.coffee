# application.js.coffee
# load jQuery beforhand
//= require jquery_ujs
//= require bootstrap
//= require jquery.autosize
//= require select2
//= require ZeroClipboard
//= require jquery.bootstrap-growl
//= require twitter-text
//= require jquery.timeago

//= require statuses

# Tweetbox
jQuery ->
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

  ##
  # Timeago
  $("abbr.timeago").timeago()
