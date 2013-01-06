#= require jquery
#= require jquery_ujs
#= require jquery-ui
#= require datepicker
#= require chosen-jquery
#= require select2
#= require ckeditor-jquery
#= require plupload
#= require plupload.settings
#= require jquery.plupload.queue
#= require plupload.html5
#= require plupload.flash
#= require rails.validations
#= require rails.validations.simple_form
#= require_tree .

# WARNING: KLUDGE
# I really don't want to create my own layout right now so I'm just replacing
# the .container with .container-fluid so the app looks nice
# $('.container').removeClass('container').addClass('container-fluid')