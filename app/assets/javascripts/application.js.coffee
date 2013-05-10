# application.js.coffee
# load jQuery beforhand
//= require jquery_ujs
//= require bootstrap
//= require jquery.autosize
//= require select2

# Birdview
$ ->
  ##
  # Autosize
  $('textarea').autosize()

  $('.done').click ->
    $(this).parents('.tweet').hide()
