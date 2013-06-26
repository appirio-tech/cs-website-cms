$ ->
  if $(".search-form.challenges").length > 0
    window.challegeList = new ChallengeList

  $('#file_submission_type').change ->
    selectedValue = $(this).find(":selected").val()
    if (selectedValue == 'Code')
      $('#control-group-language').fadeIn()
    else
      $('#control-group-language').fadeOut()

class window.ChallengeList
  constructor: ->
    $("select.chosen").chosen()

    $(".label[title*=]").tooltip()
    $(".search-form a.toggle-options").toggle (event) ->
      event.preventDefault()
      $(".search-form .options").slideUp()
    , (event) ->
      event.preventDefault()
      $(".search-form .options").slideDown()

