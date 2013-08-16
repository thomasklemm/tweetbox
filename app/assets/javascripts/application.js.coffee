# application.js.coffee
# Note: add jQuery from CDN before application.js

# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# compiled file.
#
# Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
# about supported directives.

# Libraries
#= require jquery_ujs
#= require bootstrap
#= require jquery.autosize
#= require select2
#= require ZeroClipboard
#= require twitter-text
#= require jquery.timeago
# = require jquery.infinitescroll

# Tweetbox
#= require statuses
#= require tweets

# Submit form when a radio button is selected
jQuery.fn.submitOnCheck = ->
  # @find('input[type=submit]').remove()
  @find('input[type=radio]').hide()
  @find('input[type=radio]').click ->
    $(this).parents('form').submit()
  # Return this for chaining
  this

# Tweetbox
jQuery ->
  ##
  # Autosize
  $('textarea').autosize()

  # Submit forms on radio selection
  $('.edit_lead').submitOnCheck()

  ##
  # ZeroClipboard
  clip = new ZeroClipboard($('.copy-button'), {
    moviePath: "/ZeroClipboard.swf"
  })

  # Give some feedback about what has just been copied to the clipboard
  # clip.on 'complete', (client, args) ->
  #   $.bootstrapGrowl('Copied to Clipboard: \n "' + args.text + '"', {
  #       type: 'success'
  #     })

  ##
  # Timeago
  $("abbr.timeago").timeago()

  ##
  # Embedly
  $.embedly.defaults.key = '5215692271f6455882608f229709215a'
  $('.public-tweet .text a:not(.user-mention)').embedly
    method: 'afterParent',
    # de.slideshare.com manually embedded
    urlRe: /((http:\/\/(www\.flickr\.com\/photos\/.*|flic\.kr\/.*|.*imgur\.com\/.*|xkcd\.com\/.*|www\.xkcd\.com\/.*|imgs\.xkcd\.com\/.*|instagr\.am\/p\/.*|instagram\.com\/p\/.*|www\.slideshare\.net\/.*\/.*|www\.slideshare\.net\/mobile\/.*\/.*|slidesha\.re\/.*|scribd\.com\/doc\/.*|www\.scribd\.com\/doc\/.*|scribd\.com\/mobile\/documents\/.*|www\.scribd\.com\/mobile\/documents\/.*|www\.sliderocket\.com\/.*|sliderocket\.com\/.*|app\.sliderocket\.com\/.*|portal\.sliderocket\.com\/.*|beta-sliderocket\.com\/.*|maps\.google\.com\/maps\?.*|maps\.google\.com\/\?.*|maps\.google\.com\/maps\/ms\?.*|tumblr\.com\/.*|.*\.tumblr\.com\/post\/.*|pastebin\.com\/.*|pastie\.org\/.*|www\.pastie\.org\/.*|speakerdeck\.com\/.*\/.*|www\.kiva\.org\/lend\/.*|.*\.uservoice\.com\/.*\/suggestions\/.*|formspring\.me\/.*|www\.formspring\.me\/.*|formspring\.me\/.*\/q\/.*|www\.formspring\.me\/.*\/q\/.*|.*youtube\.com\/watch.*|.*\.youtube\.com\/v\/.*|youtu\.be\/.*|.*\.youtube\.com\/user\/.*|.*\.youtube\.com\/.*#.*\/.*|m\.youtube\.com\/watch.*|m\.youtube\.com\/index.*|.*\.youtube\.com\/profile.*|.*\.youtube\.com\/view_play_list.*|.*\.youtube\.com\/playlist.*|vids\.myspace\.com\/index\.cfm\?fuseaction=vids\.individual&videoid.*|www\.myspace\.com\/index\.cfm\?fuseaction=.*&videoid.*|video\.yahoo\.com\/watch\/.*\/.*|video\.yahoo\.com\/network\/.*|sports\.yahoo\.com\/video\/.*|.*viddler\.com\/v\/.*|www\.vimeo\.com\/groups\/.*\/videos\/.*|www\.vimeo\.com\/.*|vimeo\.com\/groups\/.*\/videos\/.*|vimeo\.com\/.*|vimeo\.com\/m\/#\/.*|player\.vimeo\.com\/.*|www\.thedailyshow\.com\/watch\/.*|www\.thedailyshow\.com\/full-episodes\/.*|www\.thedailyshow\.com\/collection\/.*\/.*\/.*|movies\.yahoo\.com\/movie\/.*\/video\/.*|movies\.yahoo\.com\/movie\/.*\/trailer|movies\.yahoo\.com\/movie\/.*\/video|app\.wistia\.com\/embed\/medias\/.*|wistia\.com\/.*|.*\.wistia\.com\/.*|.*\.wi\.st\/.*|wi\.st\/.*|theguardian\.com\/.*\/video\/.*\/.*\/.*\/.*|www\.theguardian\.com\/.*\/video\/.*\/.*\/.*\/.*|guardian\.co\.uk\/.*\/video\/.*\/.*\/.*\/.*|www\.guardian\.co\.uk\/.*\/video\/.*\/.*\/.*\/.*|soundcloud\.com\/.*|soundcloud\.com\/.*\/.*|soundcloud\.com\/.*\/sets\/.*|soundcloud\.com\/groups\/.*|snd\.sc\/.*|open\.spotify\.com\/.*|spoti\.fi\/.*))|(https:\/\/(maps\.google\.com\/maps\?.*|maps\.google\.com\/\?.*|maps\.google\.com\/maps\/ms\?.*|speakerdeck\.com\/.*\/.*|.*youtube\.com\/watch.*|.*\.youtube\.com\/v\/.*|www\.vimeo\.com\/.*|vimeo\.com\/.*|player\.vimeo\.com\/.*|app\.wistia\.com\/embed\/medias\/.*|wistia\.com\/.*|.*\.wistia\.com\/.*|.*\.wi\.st\/.*|wi\.st\/.*|soundcloud\.com\/.*|soundcloud\.com\/.*\/.*|soundcloud\.com\/.*\/sets\/.*|soundcloud\.com\/groups\/.*|open\.spotify\.com\/.*)))/i,
    query:
      maxwidth: 560,
      wmode: 'transparent'

  ##
  # Alerts / Flash messages
  $('.alert').click ->
    $(this).remove()

