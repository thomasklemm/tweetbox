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
#
#= require jquery
#= require jquery_ujs
#= require bootstrap

# jQuery ->
#   $('form').on 'click', '.remove_fields', (event) ->
#     $(this).closest('.field').remove()
#     event.preventDefault()

#   $('form').on 'click', '.add_fields', (event) ->
#     time = new Date().getTime()
#     regexp = new RegExp($(this).data('id'), 'g')
#     $(this).before($(this).data('fields').replace(regexp, time))
#     event.preventDefault()

jQuery.fn.submitOnCheck = ->
  # @find('input[type=submit]').remove()
  @find('input[type=radio]').hide()
  @find('input[type=radio]').click ->
    $(this).parents('form').submit()
  # Return this for chaining
  this

jQuery ->
  # Submit forms on radio selection
  $('.edit_lead').submitOnCheck()
