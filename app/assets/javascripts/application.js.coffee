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

# jQuery via CDN

# Libraries
#= require jquery_ujs

#= require twitter/bootstrap/transition
#= require twitter/bootstrap/alert
#= require twitter/bootstrap/dropdown
#= require twitter/bootstrap/tooltip
#= require twitter/bootstrap/button
#= require twitter/bootstrap/collapse

#= require jquery.autosize
#= require select2
#= require ZeroClipboard
#= require twitter-text
#= require jquery.timeago

#= require tweets

# Submit forms in Dash on Check
jQuery.fn.submitOnCheck = ->
  # Customized for Bootstrap 3 button groups
  @find('.btn-group label').click ->
    # Set checked value
    $(this).find('input[type=radio]').attr('checked', 'checked')
    # Submit form
    $(this).parents('form').submit()
  # Return this for chaining
  this

jQuery.fn.fastResolve = ->
  @find('.resolve-and-activate-btn').click ->
    $(this).parent('.tweet').toggleClass('incoming').toggleClass('resolved')

# Timeago settings
# $.extend($.timeago, {
#   settings: {
#     refreshMillis: 30000,
#     allowFuture: false,
#     localeTitle: false,
#     cutoff: 0,
#     strings: {
#       prefixAgo: null,
#       prefixFromNow: null,
#       suffixAgo: null,
#       suffixFromNow: "from now",
#       seconds: "just now",
#       minute: "just now",
#       minutes: "%d minutes",
#       hour: "an hour",
#       hours: "%d hours",
#       day: "a day",
#       days: "%d days",
#       month: "a month",
#       months: "%d months",
#       year: "a year",
#       years: "%d years",
#       wordSeparator: " ",
#       numbers: []
#     }
#   }
# })

# Angular
@StatusController = ($scope) ->
  # Character counter
  $scope.characterCount = (model) ->
    twttr.txt.getTweetLength(model)

  $scope.copyText = ->
    $('#status_twitter_text').focus()
    if @statusTwitterText == ''
      # 116(text) + 1(space) + 23(https url)
      @statusTwitterText = @statusText.slice(0, 113) + '...'

# Tweetbox
jQuery ->
  # Slide up flash messages on click
  $('.alert').click ->
    $(this).slideUp(200)

  # Expand textareas automatically
  $('textarea').autosize()

  # Timeago
  $('abbr.timeago').timeago()

# Scroll pagination infinitely
  if $('.pagination').length
    $(window).scroll ->
      url = $('.pagination a[rel=next]').attr('href')
      if url && $(window).scrollTop() > $(document).height() - $(window).height() - 50
        $('.pagination').html("<i class='icon-spinner icon-spin'></i> Loading more...")
        $.getScript(url)
    $(window).scroll()

  # Scroll tweets infinitely
  if $('.tweets-pagination').length
    min_id_on_page = null
    $(window).scroll ->
      url = $('#tweets').data('next-page-url')
      flow = $('#tweets').attr('data-flow')
      max_id = $('#tweets').attr('data-min-id') || ''
      url = url + '?flow=' + flow + '&max_id=' + max_id
      if url && $(window).scrollTop() > $(document).height() - $(window).height() - 50
        # Both values are strings
        return if max_id == min_id_on_page
        min_id_on_page = max_id
        spinner = "<i class='icon-spinner icon-spin'></i> Loading more..."
        $('.tweets-pagination').html(spinner)
        $.getScript(url)
    $(window).scroll()

  # Submit lead forms in dash on radio selection
  $('.edit_lead').submitOnCheck()

  # ZeroClipboard
  clip = new ZeroClipboard($('.copy-button'), {
    moviePath: "/ZeroClipboard.swf"
  })

  # Embedly
  $.embedly.defaults.key = '5215692271f6455882608f229709215a'

  $('.public-tweet .text a:not(.user-mention)').embedly
    method: 'afterParent',
    urlRe: /((http:\/\/(www\.flickr\.com\/photos\/.*|flic\.kr\/.*|.*dribbble\.com\/shots\/.*|drbl\.in\/.*|gist\.github\.com\/.*|www\.slideshare\.net\/.*\/.*|www\.slideshare\.net\/mobile\/.*\/.*|slidesha\.re\/.*|polldaddy\.com\/community\/poll\/.*|polldaddy\.com\/poll\/.*|answers\.polldaddy\.com\/poll\/.*|www\.kickstarter\.com\/projects\/.*\/.*|www\.sliderocket\.com\/.*|sliderocket\.com\/.*|app\.sliderocket\.com\/.*|portal\.sliderocket\.com\/.*|beta-sliderocket\.com\/.*|chart\.ly\/symbols\/.*|chart\.ly\/.*|maps\.google\.com\/maps\?.*|maps\.google\.com\/\?.*|maps\.google\.com\/maps\/ms\?.*|pastebin\.com\/.*|pastie\.org\/.*|www\.pastie\.org\/.*|cl\.ly\/.*|cl\.ly\/.*\/content|speakerdeck\.com\/.*\/.*|storify\.com\/.*\/.*|prezi\.com\/.*\/.*|.*\.uservoice\.com\/.*\/suggestions\/.*|formspring\.me\/.*|www\.formspring\.me\/.*|formspring\.me\/.*\/q\/.*|www\.formspring\.me\/.*\/q\/.*|jsfiddle\.net\/.*|.*youtube\.com\/watch.*|.*\.youtube\.com\/v\/.*|youtu\.be\/.*|.*\.youtube\.com\/user\/.*|.*\.youtube\.com\/.*#.*\/.*|m\.youtube\.com\/watch.*|m\.youtube\.com\/index.*|.*\.youtube\.com\/profile.*|.*\.youtube\.com\/view_play_list.*|.*\.youtube\.com\/playlist.*|video\.google\.com\/videoplay\?.*|.*viddler\.com\/v\/.*|www\.livestream\.com\/.*|new\.livestream\.com\/.*|www\.vzaar\.com\/videos\/.*|vzaar\.com\/videos\/.*|www\.vzaar\.tv\/.*|vzaar\.tv\/.*|vzaar\.me\/.*|.*\.vzaar\.me\/.*|www\.vimeo\.com\/groups\/.*\/videos\/.*|www\.vimeo\.com\/.*|vimeo\.com\/groups\/.*\/videos\/.*|vimeo\.com\/.*|vimeo\.com\/m\/#\/.*|player\.vimeo\.com\/.*|www\.ted\.com\/talks\/.*\.html.*|www\.ted\.com\/talks\/lang\/.*\/.*\.html.*|www\.ted\.com\/index\.php\/talks\/.*\.html.*|www\.ted\.com\/index\.php\/talks\/lang\/.*\/.*\.html.*|www\.theonion\.com\/video\/.*|theonion\.com\/video\/.*|app\.wistia\.com\/embed\/medias\/.*|wistia\.com\/.*|.*\.wistia\.com\/.*|.*\.wi\.st\/.*|wi\.st\/.*|www\.facebook\.com\/photo\.php.*|www\.facebook\.com\/video\/video\.php.*|www\.facebook\.com\/v\/.*|plus\.google\.com\/.*|www\.google\.com\/profiles\/.*|google\.com\/profiles\/.*|live\.huffingtonpost\.com\/r\/segment\/.*\/.*|soundcloud\.com\/.*|soundcloud\.com\/.*\/.*|soundcloud\.com\/.*\/sets\/.*|soundcloud\.com\/groups\/.*|snd\.sc\/.*|open\.spotify\.com\/.*|spoti\.fi\/.*|www\.rdio\.com\/#\/artist\/.*\/album\/.*|www\.rdio\.com\/artist\/.*\/album\/.*))|(https:\/\/(gist\.github\.com\/.*|maps\.google\.com\/maps\?.*|maps\.google\.com\/\?.*|maps\.google\.com\/maps\/ms\?.*|speakerdeck\.com\/.*\/.*|.*youtube\.com\/watch.*|.*\.youtube\.com\/v\/.*|www\.vimeo\.com\/.*|vimeo\.com\/.*|player\.vimeo\.com\/.*|app\.wistia\.com\/embed\/medias\/.*|wistia\.com\/.*|.*\.wistia\.com\/.*|.*\.wi\.st\/.*|wi\.st\/.*|www\.facebook\.com\/photo\.php.*|www\.facebook\.com\/video\/video\.php.*|www\.facebook\.com\/v\/.*|plus\.google\.com\/.*|soundcloud\.com\/.*|soundcloud\.com\/.*\/.*|soundcloud\.com\/.*\/sets\/.*|soundcloud\.com\/groups\/.*|open\.spotify\.com\/.*)))/i,
    query:
      maxwidth: 560,
      wmode: 'transparent'

  # Polling for new tweets
  if $('#tweets').length > 0
    Tweets.poll()

  # Show new tweets on click
  $('#show-tweets a').click Tweets.showTweets

  # Resolve tweets quickly
  # $('.tweet').fastResolve()
