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
#= require jquery.bootstrap-growl
#= require twitter-text
#= require jquery.timeago

# Tweetbox
#= require statuses

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
  clip.on 'complete', (client, args) ->
    $.bootstrapGrowl('Copied to Clipboard: \n "' + args.text + '"', {
        type: 'success'
      })

  ##
  # Timeago
  $("abbr.timeago").timeago()

  ##
  # Embedly
  $.embedly.defaults.key = '5215692271f6455882608f229709215a'
  $('.public-tweet a').embedly
    query:
      maxwidth: 900,
      maxheight: 600

